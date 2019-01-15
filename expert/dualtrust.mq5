#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define  N  5 //K线根数
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
input double ks = 0.6;
CTrade trade;
CPositionInfo pos;
void OnTick()
  {
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   int HH_index=iHighest(NULL,PERIOD_CURRENT,MODE_HIGH,N,0);
   double HH = iHigh(_Symbol,PERIOD_CURRENT,HH_index); 
   
   int LL_index=iLowest(NULL,PERIOD_CURRENT,MODE_LOW,N,0);
   double LL = iLow(_Symbol,PERIOD_CURRENT,LL_index);
   
   int HC_index=iHighest(NULL,PERIOD_CURRENT,MODE_CLOSE,N,0);
   double HC = iClose(_Symbol,PERIOD_CURRENT,HC_index); 
   
   int LC_index=iLowest(NULL,PERIOD_CURRENT,MODE_CLOSE,N,0);
   double LC = iClose(_Symbol,PERIOD_CURRENT,LC_index);
   double range = MathMax(HH-LC,HC-LL);
   double open_p = iOpen(_Symbol,PERIOD_CURRENT,0);
   double top = open_p + ks* range;
   double bottom = open_p - ks*range;
   int total = PositionsTotal();
   
   //static datetime PrevBars=0;
   //datetime time_0=iTime(_Symbol,PERIOD_CURRENT,0);
   //if(time_0!=PrevBars)
   //   if(total > 0) close_all();    
   //PrevBars=time_0;
   double profits = get_profits();
   if(profits > 80) close_all();
   
   if(ask > top && total == 0) trade.Buy(0.1,NULL,0,ask-300*_Point,0,"buy");
   if(ask < bottom && total == 0) trade.Sell(0.1,NULL,0,bid+300*_Point,0,"sell");
   //if(ask > top && total == 1 && order_type() == POSITION_TYPE_SELL) trade.Buy(0.2,NULL,0,0,0,"Buy");
   //if(bid < bottom && total == 1 && order_type() == POSITION_TYPE_BUY) trade.Sell(0.2,NULL,0,0,0,"Sell");
   
   //Print("hh: ",HH," LL: ",LL," HC: ",HC," LC: ",LC," range: ",range);
  }
//+------------------------------------------------------------------+

ENUM_POSITION_TYPE order_type()
{
   ENUM_POSITION_TYPE type;
   //ulong ticket = PositionGetTicket(0);
   if(pos.SelectByIndex(0))
   {
      type = pos.PositionType();
   }
   return type;
}
void close_all()
{
   while(true)
   {
      int total = PositionsTotal();
      for(int i = 0;i < total;i++)
      {
         ulong ticket = PositionGetTicket(i);
         trade.PositionClose(ticket,-1);
      }
      if(total == 0) break;
   }
}

double get_profits()
{
   int profits = 0;
   int total = PositionsTotal();
   for(int i = 0;i < total;i++)
   {
      ulong ticket = PositionGetTicket(i);
      profits += pos.Commission() + pos.Swap() + pos.Profit();
   }
   return profits;
}
