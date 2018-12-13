//+------------------------------------------------------------------+
//|                                                    StopLimit.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
input   int dis = 400;
input double now_lot =0.1;
input double buy_stop_lot= 0.1;
input double sell_stop_lot =0.1;
input double buy_limit_lot =0.2;
input double sell_limit_lot= 0.2;
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
CTrade trade;
CPositionInfo posinfo;
void OnStart()
  {

   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double vol = 0.1;
   trade.Buy(now_lot,_Symbol,ask,0,0,"EA_BUY");
   
   trade.BuyStop(buy_stop_lot,ask+dis*_Point,_Symbol,0,0,0,0,"buystop");
   trade.BuyStop(buy_stop_lot,ask+dis*_Point*2,_Symbol,0,0,0,0,"buystop2");
   
   trade.SellStop(sell_stop_lot,bid-dis*_Point,_Symbol,0,0,0,0,"sellstop1");
   trade.SellStop(sell_stop_lot,bid-dis*_Point*2,_Symbol,0,0,0,0,"sellstop2");
   
   trade.BuyLimit(buy_limit_lot,ask-dis*_Point,_Symbol,0,0,0,0,"BuyLimit");
   trade.SellLimit(sell_limit_lot,bid+dis*_Point*2,_Symbol,0,0,0,0,"SellLimit");
//      ulong    ticket; 
//   double   open_price; 
//   double   initial_volume; 
//   datetime time_setup; 
//   string   symbol; 
//   string   type; 
//   long     order_magic;
//   int     total=OrdersTotal(); 
////--- 反复检查通过订单 
//   for(int i=0;i<total;i++) 
//     { 
//      //--- 通过列表中的仓位返回订单报价 
//      if(ticket=OrderGetTicket(i)) 
//        { 
//         //--- 返回订单属性 
//         open_price    =OrderGetDouble(ORDER_PRICE_OPEN); 
//         time_setup    =(datetime)OrderGetInteger(ORDER_TIME_SETUP); 
//         symbol        =OrderGetString(ORDER_SYMBOL); 
//         order_magic   =OrderGetInteger(ORDER_MAGIC); 
//
//         initial_volume=OrderGetDouble(ORDER_VOLUME_INITIAL); 
//         type          =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE))); 
//         //--- 准备和显示订单信息 
//         printf("#ticket %d %s %G %s at %G was set up at %s", 
//                ticket,                 // 订单报价 
//                type,                   // 类型 
//                initial_volume,         // 已下交易量 
//                symbol,                 // 交易品种 
//                open_price,             // 规定的开盘价 
//                TimeToString(time_setup)// 下订单时间 
//                ); 
//        } 
//     }
   
  }
//+------------------------------------------------------------------+
