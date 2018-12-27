
//+------------------------------------------------------------------+
//|                    Trade in Channel(barabashkakvn's edition).mq5 |
//|                                  Copyright © 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, George-on-Don"
#property link      "http://www.forex.aaanet.ru"
#property version   "1.001"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
struct Zig 
  { 
   int          pos; 
   double       price; 
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit()
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnStart()
  {
   ObjectsDeleteAll(0,0,-1);
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   int handle = iCustom(NULL,0,"Examples\\ZigZag",12,5,3); 
  
   double zigAll[];
   Zig zigs[]; //zig是筛选极值以后的，zigall里面有包含0的
   ArraySetAsSeries(zigAll,true);
   ArrayInitialize(zigAll,0);  
   int copy=CopyBuffer(handle,0,0,200,zigAll); 
   get_zig(zigAll,zigs);
   Print(zigs[1].pos);
   double temp_high = iHigh(_Symbol,0,zigs[1].pos);
   double temp_low = iLow(_Symbol,0,zigs[1].pos);
   for(int i = zigs[1].pos-1;i>=0;i--)
   {


      double high = iHigh(_Symbol,0,i);
      double low = iLow(_Symbol,0,i);
      temp_high = MathMax(temp_high,high);
      temp_low = MathMax(temp_low,low);
      if(high < temp_high && low < temp_low)
      {
         ObjectCreate(0,"h"+i,OBJ_ARROW_UP,0,iTime(_Symbol,0,i),temp_high);
         ObjectCreate(0,"l"+i,OBJ_ARROW_DOWN,0,iTime(_Symbol,0,i),temp_low);
         break;
      }
      //Print(iLow(_Symbol,0,i)," time: ",iTime(_Symbol,0,i));
   }
   //是否连续下跌
   //double high[],low[];
   //ArraySetAsSeries(high,true);ArraySetAsSeries(low,true);
   //CopyHigh(_Symbol,0,0,100,high);CopyHigh(_Symbol,0,0,100,low);
   //Print(zig[0]);
  }

int get_zig(double &zigAll[],Zig &zigs[])
{
   for(int i = 0;i < ArraySize(zigAll) -1;i++)
   {
     static int j;
     if(zigAll[i] !=0)
     { 
      j++;
      ArrayResize(zigs,j);
      zigs[j-1].price = zigAll[i];
      zigs[j-1].pos = i;  
     } 
   }
   return (zigs[0].price>zigs[1].price)?1:-1;
}
