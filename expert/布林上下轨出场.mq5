//+------------------------------------------------------------------+
//|                                                         band.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo posinfo;
int handle_band,handle_rsi;
input int sl_point = 50;//增加止损点数
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   handle_band = iBands(_Symbol,0,50,0,2,PRICE_CLOSE);
   handle_rsi = iRSI(_Symbol,0,9,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double middle[],up[],down[],rsi[],high,low,ask,bid;
   ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   ulong ticket_sell = get_ticket_by_type(POSITION_TYPE_SELL);
   ulong ticket_buy = get_ticket_by_type(POSITION_TYPE_BUY);
   ArraySetAsSeries(middle,true);
   ArraySetAsSeries(up,true);
   ArraySetAsSeries(down,true);
   ArraySetAsSeries(rsi,true);
   CopyBuffer(handle_band,0,0,100,middle);
   CopyBuffer(handle_band,1,0,100,up);
   CopyBuffer(handle_band,2,0,100,down);
   CopyBuffer(handle_rsi,0,0,100,rsi);
   int high_index = iHighest(_Symbol,0,MODE_HIGH,5,0);
   int low_index = iLowest(_Symbol,0,MODE_LOW,5,0);
   
   high = iHigh(_Symbol,0,high_index);
   low = iLow(_Symbol,0,low_index);
   double sell_sl = high + sl_point*_Point;
   double buy_sl = low - sl_point*_Point;
   if(posinfo.SelectByTicket(ticket_sell))
   {
      if(posinfo.StopLoss() == 0.0) trade.PositionModify(ticket_sell,sell_sl,0);
      if(bid < down[0]) trade.PositionClose(ticket_sell,-1);
   } 
   if(posinfo.SelectByTicket(ticket_buy))
   {
      if(ask > up[0]) trade.PositionClose(ticket_buy,-1);
      if(posinfo.StopLoss() == 0.0) trade.PositionModify(ticket_buy,buy_sl,0);
   } 

//   close1 = iClose(_Symbol,0,low_index);
//   bool cond_sell = high1 > up[1] && close1 <= up[1] && rsi[1] > 70;
//   bool cond_buy = low1 < down[1] && close1 >= down[1] && rsi[1] < 30;
//   double sell_sl = high1 +50*_Point;
//   double buy_sl = low1 - 50*_Point;
//
//   if(!is_exist(POSITION_TYPE_SELL) && cond_sell) trade.Sell(1,_Symbol,bid,sell_sl,0,"sell");
//   if(!is_exist(POSITION_TYPE_BUY) && cond_buy) trade.Buy(1,_Symbol,ask,buy_sl,0,"buy");
//   
//   if(is_exist(POSITION_TYPE_BUY) && ask > middle[0]) close_half(POSITION_TYPE_BUY);
//   if(is_exist(POSITION_TYPE_BUY) && cond_sell) close_all(POSITION_TYPE_BUY);
//   
//   if(is_exist(POSITION_TYPE_SELL) && bid < middle[0]) close_half(POSITION_TYPE_SELL);
//   if(is_exist(POSITION_TYPE_SELL) && cond_buy) close_all(POSITION_TYPE_SELL);
  // Print(rsi[1]);
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+

bool is_exist(ENUM_POSITION_TYPE type)
{
 bool  res = false;
 for(int i = 0;i < PositionsTotal();i++)
 {
   if(posinfo.SelectByIndex(i)) 
       if(posinfo.PositionType() == type) return true;
 }
 
 return res;
}

void close_all(ENUM_POSITION_TYPE type)
{
   int total = PositionsTotal();
   for(int i = 0;i < total;i++)
   {
      if(posinfo.SelectByIndex(i)) 
         if(posinfo.PositionType() == type) trade.PositionClose(posinfo.Identifier(),-1);;
   }

}

void close_half(ENUM_POSITION_TYPE type)
{
   int total = PositionsTotal();
   for(int i = 0;i < total;i++)
   {
      if(posinfo.SelectByIndex(i)) 
         if(posinfo.PositionType() == type && posinfo.Volume() == 1.0) trade.PositionClosePartial(posinfo.Identifier(),0.5*posinfo.Volume(),-1);
   }
}

ulong get_ticket_by_type(ENUM_POSITION_TYPE type)
{
   for(int i = PositionsTotal()-1;i >= 0;i--)
   {
       if(posinfo.SelectByIndex(i))
         if(posinfo.Symbol() != _Symbol) continue; 
         if(posinfo.PositionType() == type) return posinfo.Identifier();
   }
   return 0;
}