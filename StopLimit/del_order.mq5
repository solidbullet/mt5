//+------------------------------------------------------------------+
//|                                                      DelStop.mq5 |
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
void OnStart()
  {
   int ticket;
   int     total=OrdersTotal(); 
//--- 反复检查通过订单 
   for(int j = 0;j <30;j++)
   {
      for(int i=0;i<total;i++) 
        { 
         //--- 通过列表中的仓位返回订单报价 
         if(ticket=OrderGetTicket(i)) 
           { 
            trade.OrderDelete(ticket);
           } 
        }
      if(total ==0) break;
   }
  }
//+------------------------------------------------------------------+
