//+------------------------------------------------------------------+
//|                                                         list.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

input   int dis = 400;
input double now_lot =0.1;
input double buy_stop_lot= 0.1;
input double sell_stop_lot =0.1;
input double buy_limit_lot =0.1;
input double sell_limit_lot= 0.1;
 double               InpVirtualProfit        = 30;             // Virtual Profit (in money)
CTrade trade;
CPositionInfo  m_position;                   // trade position object
CSymbolInfo    symbol_info;         // Объект-CSymbolInfo
int            prev_total;          // Количество позиций на прошлой проверке


int handle;
sinput ulong               m_magic                 = 13433244;       // magic number

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(m_magic);
   //handle = iCustom(_Symbol,0,"Examples\\Fractals");
   //ChartIndicatorAdd(0,0,handle);  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Profit() > InpVirtualProfit) close_all();
   if(CalculateAllPositions() == 0 && OrdersTotal() == 0) guadan();
  
  //if(total == 6) ExpertRemove();

  }
//+------------------------------------------------------------------+

void guadan()
{
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double vol = 0.1;
   trade.Buy(now_lot,_Symbol,ask,0,0,"EA_BUY");
   
   trade.SellStop(sell_stop_lot,bid-dis*_Point,_Symbol,0,0,0,0,"sellstop1");
   trade.BuyLimit(buy_limit_lot,ask-dis*_Point*2,_Symbol,0,0,0,0,"BuyLimit1");
   trade.SellStop(sell_stop_lot,bid-dis*_Point*3,_Symbol,0,0,0,0,"sellstop2");
   trade.BuyLimit(buy_limit_lot,ask-dis*_Point*4.5,_Symbol,0,0,0,0,"BuyLimit2");
   
   trade.BuyStop(buy_stop_lot,ask+dis*_Point,_Symbol,0,0,0,0,"buystop1");
   trade.BuyStop(buy_stop_lot,ask+dis*_Point*2,_Symbol,0,0,0,0,"buystop2");
   trade.SellLimit(sell_limit_lot,bid+dis*_Point*4,_Symbol,0,0,0,0,"SellLimit1");
   trade.SellLimit(sell_limit_lot,bid+dis*_Point*5,_Symbol,0,0,0,0,"SellLimit2");
   
   
   
   
}

int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==_Symbol)  //&& m_position.Magic()==m_magic
            total++;
   return(total);
  }
  
double Profit()
{
   double total_profit=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()== _Symbol ) 
            total_profit=m_position.Commission()+m_position.Swap()+m_position.Profit();//&& m_position.Magic()==m_magic
   return(total_profit);
}
void close_all()
{
   for(int j=PositionsTotal()-1;j>=0;j--) // returns the number of current positions
      if(m_position.SelectByIndex(j)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==_Symbol)
         {
            trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol  
         }
   removeAllOrder();
}
void removeAllOrder()
{
   int     total=OrdersTotal();
   int ticket; 
   for(int j = 0;j <30;j++)
   {
      for(int i=0;i<total;i++) 
        { 
         if(ticket=OrderGetTicket(i)) 
           { 
            trade.OrderDelete(ticket);
           } 
        }
      if(total ==0) break;
   }
}