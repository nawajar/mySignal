//+------------------------------------------------------------------+
//|                                        |
//+------------------------------------------------------------------+
#property copyright "Pender"
#property link      "xxx@gmai.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

#property indicator_buffers 7
#property indicator_color1 clrBlack
#property indicator_color2 clrGreen
#property indicator_color3 clrRed
#property indicator_color4 clrYellow
#property indicator_color5 clrMediumBlue
#property indicator_color6 LimeGreen
#property indicator_color7 Red
#property indicator_separate_window

extern string SoundAlertFileLong   = "alert.wav";

extern int RSI_Period = 13; 
extern int RSI_Price = 0;
extern int Signal_Line = 2;      
extern int Signal_Type = 0;
extern int Trade_Line = 7;   
extern int Trade_Type = 0;
extern int Market_Line = 34;

int vOnbar = 0;
int alertC = 0;
int vOnbarDown = 0;

double RSIBUFF[],Signal[],Trade[],Market[] , MAHistory[] , arrowBuff[] , arrowDownBuff[];

int init()
   {
   IndicatorShortName("Pender");
   SetIndexBuffer(0,RSIBUFF);
   SetIndexStyle(0,NULL);
   SetIndexLabel(0,"RSI");
   
   SetIndexBuffer(1,Signal);
   SetIndexStyle(1,DRAW_LINE,0,2);
   SetIndexLabel(1,"Signal");
  
   SetIndexBuffer(2,Trade);
   SetIndexStyle(2,DRAW_LINE,0,2);
   SetIndexLabel(2,"Trade");
   
   SetIndexBuffer(3,Market);
   SetIndexStyle(3,DRAW_LINE,2,0);
   SetIndexLabel(3,"Market");
   
   SetIndexBuffer(4,MAHistory);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexLabel(4,"Trade His");
   
   SetIndexBuffer(5,arrowBuff); 
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexArrow(5,233);
   SetIndexEmptyValue(5,0.0);
   
   SetIndexBuffer(6,arrowDownBuff); 
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexArrow(6,238);
   SetIndexEmptyValue(6,0.0);
   
   SetLevelValue(0,68);
   SetLevelValue(1,50);
   SetLevelValue(2,32); 
   SetLevelStyle(STYLE_SOLID,0,White);
  
   
   
   return(0);
   
   }
   
int start()
   {  
   //double MA,RSI[];
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   datetime date[];
   ArrayResize(date,Bars);
   CopyTime(Symbol(),Period(),0,Bars,date);
   for(int i=limit; i>=0; i--)
   {
      RSIBUFF[i] = iRSI(NULL,0,RSI_Period,RSI_Price,i);
   }
      
   for(int j=limit-1; j>=0; j--)
   {
      Signal[j] = (iMAOnArray(RSIBUFF,0,Signal_Line,0,Signal_Type,j));
      Trade[j] = (iMAOnArray(RSIBUFF,0,Trade_Line,0,Trade_Type,j));
      Market[j] = (iMAOnArray(RSIBUFF,0,Market_Line,0,0,j));
      MAHistory[j] = (iMAOnArray(RSIBUFF,0,Signal_Line,0,Signal_Type,j+1));
        
       double GreenLine = Signal[j+1];
       double RedLine = Trade[j+1];
       double YellowLine = Market[j+1];
       double MAHistoryLine = MAHistory[j+1];
       bool conditionGreen = (GreenLine > 50 && MAHistoryLine < 50 && GreenLine > RedLine && GreenLine > YellowLine && (vOnbar ==0)) ? true : false;
       bool conditionRed = (GreenLine < 50 && MAHistoryLine > 50 && GreenLine < RedLine && GreenLine < YellowLine && (vOnbarDown == 0)) ? true : false;
      
      if(conditionGreen)
         {
               printf( " ====== Pender Signal ===BUY=== "+ TimeCurrent() + "  ||  " + Symbol()+ "  ||  "  + DoubleToString(GreenLine,5) + "  ||  "  + DoubleToString(RedLine,5));  
               vOnbar = 1;
               //nawa.ja do not delete arrowBuff[j+1] = GreenLine +(50 *Point);
               VlineCreate(j, Time[j+1] , clrGreen);
               DisplayText("Trend" , "BULL CROSS" , clrLawnGreen , 1 , 1 , 20 , 20);
               ChartRedraw();
     
         }else if(GreenLine < 50)
          {
                 vOnbar = 0;
          }
          
      if(conditionRed)
         {
             
            printf( " ====== Pender Signal ===SELL=== "+ TimeCurrent() + "  ||  " + Symbol()+ "  ||  " + DoubleToString(GreenLine,5) + "  ||  " + DoubleToString(RedLine,5)); 
            vOnbarDown = 1;
            DisplayText("Trend" , "ฺBEAR CROSS" , clrRed , 1 , 1 , 20 , 20);
            //nawa.ja do not delete arrowDownBuff[j-1] = RedLine -(100 *Point);    
            VlineCreate(j+1, Time[j+1] , clrRed);
            
         }
         else if(GreenLine > 50)
          {
            vOnbarDown = 0;         
          }
         
    
      
      }
      
     

   
   return(0);
   }
   
   bool VlineCreate(int id , datetime time , color clor)
    {
   
      ObjectDelete(IntegerToString(id));
      ObjectCreate(IntegerToString(id),OBJ_VLINE,0,time,0);
      ObjectSet(IntegerToString(id),OBJPROP_COLOR,clor);
      ObjectSet(IntegerToString(id),OBJPROP_STYLE,3);
      ObjectSet(IntegerToString(id),OBJPROP_WIDTH,1);
      ObjectSet(IntegerToString(id),OBJPROP_BACK,true);
      return true;
    } 
    
    bool DisplayText(string ojbName , string msg  , color clo , int window ,int conner , int x , int y){
      ObjectDelete(ojbName);
      ObjectCreate(ojbName, OBJ_LABEL, window, 0, 0);
      ObjectSetText(ojbName,msg ,20, "Verdana", clo);
      ObjectSet(ojbName, OBJPROP_CORNER, conner);
      ObjectSet(ojbName, OBJPROP_XDISTANCE, x);
      ObjectSet(ojbName, OBJPROP_YDISTANCE, y);
     return true;
   }
    
    void DoAlerts(string msgText,string SoundAlertFile , string symbol , string timeF)
     {
       msgText="Pender Signal Alerts : "+": "+symbol +" "+  tFrame(timeF) +" "+msgText;  // แก้จาก TDI Pender Alerts เป็น Pender Signal Alerts
       Alert(msgText);
     }
  
    string tFrame(string t){
   
    if(t == PERIOD_M1){
      return "M1";
    }
     if(t == PERIOD_M5){
      return "M5";
    }
    if(t == PERIOD_M15){
      return "M15";
    }
    if(t == PERIOD_M30){
      return "M30";
    }
     if(t == PERIOD_H1){
      return "H1";
    }
     if(t == PERIOD_H4){
      return "H4";
    }
    if(t == PERIOD_D1){
      return "D1";
    }
     if(t == PERIOD_W1){
      return "W1";
    }
    if(t == PERIOD_MN1){
      return "MN1";
    }
    return t;
    } 
     
  
 
 