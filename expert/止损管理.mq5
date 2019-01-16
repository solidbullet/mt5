#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo posinfo;
static double tp_point_sell,tp_point_buy;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
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
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double buy_open_price,sell_open_price,sl_buy,sl_sell;
   ulong ticket_sell = get_ticket_by_type(POSITION_TYPE_SELL);
   ulong ticket_buy = get_ticket_by_type(POSITION_TYPE_BUY);
   int spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   //if(posinfo.SelectByTicket(ticket_sell)) Print(posinfo.PriceOpen());
   
   if(posinfo.SelectByTicket(ticket_sell))
   {
      tp_point_sell = (posinfo.PriceOpen() - bid > tp_point_sell)?posinfo.PriceOpen() - bid:tp_point_sell;
      sell_open_price = posinfo.PriceOpen();
      if(posinfo.StopLoss() == 0.0) trade.PositionModify(ticket_sell,sell_open_price+100*_Point,0);
      sl_sell = MathAbs(posinfo.StopLoss() - posinfo.PriceOpen())/_Point;
      //Print(sl_sell);
      
   }
   if(posinfo.SelectByTicket(ticket_buy))
   {
      tp_point_buy = (ask - posinfo.PriceOpen() > tp_point_buy)?ask - posinfo.PriceOpen():tp_point_buy;
      buy_open_price = posinfo.PriceOpen();
      if(posinfo.StopLoss() == 0.0) trade.PositionModify(ticket_buy,buy_open_price-100*_Point,0);
      sl_buy = MathAbs(posinfo.StopLoss() - posinfo.PriceOpen())/_Point;
      
   }
   Print("buy: ",tp_point_buy/_Point," sell: ",tp_point_sell/_Point);
   if(tp_point_sell/_Point > 50  && ObjectFind(0,"tpsell")== -1 && sl_sell > 30 ) ObjectCreate(0,"tpsell",OBJ_ARROW_THUMB_DOWN,0,iTime(_Symbol,0,0),iOpen(_Symbol,0,0));
   if(tp_point_buy/_Point > 50 && ObjectFind(0,"tpbuy") == -1 && sl_buy > 30 ) ObjectCreate(0,"tpbuy",OBJ_ARROW_THUMB_UP,0,iTime(_Symbol,0,0),iOpen(_Symbol,0,0));
   
   if(ObjectFind(0,"tpbuy") == 0 && sl_buy > 30)
   {
      bool res = trade.PositionModify(ticket_buy,buy_open_price+5*_Point,0);
      //if(res) ObjectDelete(0,"tpbuy");
   }
   if(ObjectFind(0,"tpsell") == 0 && sl_sell > 30)
   {
      bool res = trade.PositionModify(ticket_sell,sell_open_price-5*_Point,0);
      //if(res) ObjectDelete(0,"tpsell");
   }
   
   
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
      if(result.order >0)
      {
         tp_point_buy = 0;
         tp_point_sell = 0;
      }
   
  }
//+------------------------------------------------------------------+

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