#include <MemoryFree.h>

#include <BasicLinearAlgebra.h>

#include <Pozyx.h>
#include <Pozyx_definitions.h>
#include <Wire.h>

#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>

#include <avr/pgmspace.h>

#include <avr/io.h>
#include <avr/wdt.h>

#define Reset_AVR() wdt_enable(WDTO_30MS); while(1) {} 


////////////////////////////////////////////////
////////////////// CONFIGURATION //////////////////
////////////////////////////////////////////////

const PROGMEM int DEBUG_MODE=false;  //set to false if there's not connection with serial port
const PROGMEM int APPLY_KALMAN=false; //false if we want to send raw data over ble

const char *ble_device_name="ThesisD&S";
const PROGMEM int loop_delay=0; //loop delay in milliseconds


//****POZYX SETTINGS*****
uint16_t remote_id = NULL;                            //ID of the remote device
bool remote = false;                                    //set to true to use the remote ID

uint8_t num_anchors = 4;                                    // the number of anchors
uint16_t anchors[4] = {0x6060, 0x604d, 0x6032, 0x604a};     // the network id of the anchors
int32_t anchors_x[4] = {4780,9430,12060,0};               // anchor x-coordinates in mm
int32_t anchors_y[4] = {15710,16800,3740,5950};                 // anchor y-coordinates in mm
int32_t heights[4] = {1830,1810,1880,2130};              // anchor z-coordinates in mm

uint8_t algorithm = POZYX_POS_ALG_UWB_ONLY;             // positioning algorithm to use
uint8_t dimension = POZYX_3D;                           //positioning dimension
int32_t height = 0;                                  // height of device
//************************


//********KALMAN SETTINGS**********
const PROGMEM short int measnoise=40; 
const PROGMEM short int accelnoise=2;
const PROGMEM float T=0.5;
//*********************************

////////////////////////////////////////////////
////////////////////////////////////////////////
////////////////////////////////////////////////





//**************KALMAN CONSTANTS & VARIABLES*****************

const PROGMEM float init_a[4][4]={{1,T,0,0},{0,1,0,0},{0,0,1,T},{0,0,0,1}};
const PROGMEM float init_b[4][2]={{pow(T,2)/2,0},{T,0},{0,pow(T,2)/2},{0,T}};
const PROGMEM byte init_c[2][4]={{1,0,0,0},{0,0,1,0}};
const PROGMEM int init_sz[2][2]={{pow(measnoise,2),0},{0,pow(measnoise,2)}};
const PROGMEM float init_sw[4][4]={{pow(T,4)/4,pow(T,3)/2,0,0},{pow(T,3)/2,pow(T,4),0,0},{0,0,pow(T,4)/4,pow(T,3)/2},{0,0,pow(T,3)/2,pow(T,4)}};

const PROGMEM Matrix<4,4,float>A(init_a);
const PROGMEM Matrix<4,2,float>B(init_b);
const PROGMEM Matrix<2,4,byte>C(init_c);
const PROGMEM Matrix<2,2,int>Sz(init_sz);
const PROGMEM Matrix<4,4,float>Sw(init_sw);

Matrix<4,1,int>xhat;
Matrix<4,4,float>P;
//***********************************************************


unsigned long startup_time;



void setup() {

  //SERIAL SETUP
  if(DEBUG_MODE) Serial.begin(115200);


  //PRINT STARTUP BANNER
  SerialPrintln(F("****TESI Diego & Simone - System Started****"));
  if(APPLY_KALMAN) SerialPrintln(F("KALMAN FILTER ACTIVATED"));
  SerialPrint(F("Free memory: "));
  SerialPrintln(String(freeMemory()));
  SerialPrintln(F("********************************************"));
  SerialPrintln(F(" "));


  //BLE SETUP
  ble_begin();
  //ble_set_name(ble_device_name);
  ble_set_name("ThesisD&S");


  //POZYX SETUP 
  if(Pozyx.begin() == POZYX_FAILURE){
    SerialPrintln(F("ERROR: Unable to connect to POZYX shield"));
    SerialPrintln(F("Reset required"));
    delay(100);
    abort();
  }
  Pozyx.clearDevices(remote_id);
  setPozyxAnchorsLocationManual();


  if(APPLY_KALMAN) kalman_filter_setup();
  
  delay(300);
  startup_time=millis();
}



void kalman_filter_setup(){

  //complete Sw matrix initial assignment
  Sw=Sw * pow(accelnoise,2);

  //assign initial covariance value
  P=Sw;

  //assign initial state (first measurement): coordX and coordY from pozyx, velX and velY 0
  float init_value=0; //dummy value used as parameters
  retrieveDataFromPozyx(xhat(0,0),xhat(2,0),init_value,init_value,init_value);
  xhat(1,0)=0;
  xhat(3,0)=0;

  //Serial << "Setup, initial xhat: " << xhat << '\n';
}



void loop() {

  unsigned long int timestamp=millis() - startup_time;
  int coordX;
  int coordY;
  float accX; 
  float accY;
  float heading;
  String packet_to_send;
  retrieveDataFromPozyx(coordX,coordY,accX,accY,heading);


  if(APPLY_KALMAN){ 
      
      int estimatedX;
      int estimatedY;
      applyKalmanFilter(coordX,coordY,accX,accY,estimatedX,estimatedY);  //acc returned in milligal
      packet_to_send="K"+String(timestamp)+","+String(estimatedX)+","+String(estimatedY)+","+String(heading)+"\n"; 
  } else{      
    
      packet_to_send="R"+String(timestamp)+","+String(coordX)+","+String(coordY)+","+String(accX)+","+String(accY)+","+String(heading)+"\n";   
  }

  sendDataOverBLE(packet_to_send);
  
  delay(loop_delay);
}




void retrieveDataFromPozyx(int &coordX,int &coordY,float &accX,float &accY,float &heading){

  coordinates_t position;
  sensor_data_t sensor_data;
  int status = 0;
  
  status = Pozyx.doPositioning(&position, dimension, height, algorithm);
  
  if (status == POZYX_SUCCESS){ 
  
    if(Pozyx.waitForFlag(POZYX_INT_STATUS_IMU, 10) == POZYX_SUCCESS){
     Pozyx.getAllSensorData(&sensor_data); 

      coordX=position.x;
      coordY=position.y;
      accX=sensor_data.acceleration.x;
      accY=sensor_data.acceleration.y;
      heading=sensor_data.euler_angles.heading;   
    }
     }//end pozyx success
  else{
    SerialPrintln(F("Error positioning"));
    Reset_AVR();
  }
}





void applyKalmanFilter(int coordX,int coordY,float accX,float accY,int resultX,int resultY){
  
   //acceleration
   Matrix<2,1,float>u;
   u(0,0)=accX/100; //convert 1 milligal [mg] = 0.01 [mm/s^2]
   u(1,0)=accY/100; //convert 1 milligal [mg] = 0.01 [mm/s^2]

   //noisy measured data
   Matrix<2,1,float>y;
   y(0,0)=coordX;
   y(1,0)=coordY;

   xhat=A*xhat + B*u;

   Matrix<2,1,float>Inn;
   Inn=y - C*xhat;

   Matrix<2,2,float>s;
   s = C * P * ~C + Sz;

   Matrix<4,2,float>K;
   K = A * P * ~C * s.Inverse();
   
   xhat=xhat + K*Inn;
   
   P = A * P * ~A - A * P * ~C * s.Inverse() * C * P * ~A + Sw; 

   resultX=xhat(0,0);
   resultY=xhat(2,0); 
}



void sendDataOverBLE(String data){

  if(ble_connected()){
    
        unsigned int buffer_length=data.length()+1;
        unsigned char buffer_tosend[buffer_length];
        data.toCharArray(buffer_tosend,buffer_length);
        
        SerialPrint(F("[CONNECTED]"));
        SerialPrint(data);
        
        ble_write_bytes(buffer_tosend,buffer_length);
    } else{
           
      SerialPrint(F("[IDLE]"));
      SerialPrint(data);
    } 
   
   ble_do_events();
}



void setPozyxAnchorsLocationManual(){
  
  for(int i = 0; i < num_anchors; i++){
    device_coordinates_t anchor;
    anchor.network_id = anchors[i];
    anchor.flag = 0x1; 
    anchor.pos.x = anchors_x[i];
    anchor.pos.y = anchors_y[i];
    anchor.pos.z = heights[i];
    Pozyx.addDevice(anchor, NULL);
 }
}



//DEBUG UTILITIES
void SerialPrintln(String s){
  if(DEBUG_MODE) Serial.println(s);
}

void SerialPrint(String s){
  if(DEBUG_MODE) Serial.print(s);
}






