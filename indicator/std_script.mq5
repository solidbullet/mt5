//+------------------------------------------------------------------+
//|                                                      cal_std.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
input int                  CAL_COUNT=100;                // 移动 
input int                  ma_period=30;              // 平均周期 
input int                  ma_shift=0;                // 移动 
input ENUM_MA_METHOD       ma_method=MODE_SMA;        // 平滑类型 
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 价格类型 
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;     // 时间帧 

double         iStdDevBuffer[]; 
double         iMaBuffer[];
double close[];
double ratio[];

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   ArraySetAsSeries(iStdDevBuffer,true);
   ArraySetAsSeries(iMaBuffer,true);
   ArraySetAsSeries(close,true);
   
   int bars=Bars(_Symbol,period);

   int handle=iStdDev(_Symbol,period,ma_period,ma_shift,ma_method,applied_price); 
   int handleMa=iMA(_Symbol,period,ma_period,ma_shift,ma_method,applied_price); 
   int calculated=BarsCalculated(handle); 
   int calculated2=BarsCalculated(handleMa);

   CopyBuffer(handle,0,0,CAL_COUNT,iStdDevBuffer);
   CopyBuffer(handleMa,0,0,CAL_COUNT,iMaBuffer);
   CopyClose(_Symbol,period,0,CAL_COUNT,close);
   for(int i = 0;i < CAL_COUNT;i++)
   {
      ArrayResize(ratio,i+1);
      ratio[i] =   (close[i] - iMaBuffer[i])/iStdDevBuffer[i];
   }
   //Print(close[0]," iStdDevBuffer ",iStdDevBuffer[0]," ma: ",iMaBuffer[0]);
   //double ratio =   (close[0] - iMaBuffer[0])/iStdDevBuffer[0];
   Print(ratio[0]);
   
  }
//+------------------------------------------------------------------+
