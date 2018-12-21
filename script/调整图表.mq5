//+------------------------------------------------------------------+
//|                                                         调整图表.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   long currChart,prevChart=ChartFirst(); 
   int i=0,limit=100; 
   while(i<limit)// 不允许超过100个打开的窗口 
     { 
      ObjectsDeleteAll(prevChart,0,-1);
      ChartSetInteger(prevChart,CHART_MODE,CHART_CANDLES);
      ChartSetInteger(prevChart,CHART_SHOW_GRID,false);
      ChartSetInteger(prevChart,CHART_SHIFT,true);
      ChartSetInteger(prevChart,CHART_SCALE,3);
      //bool res = ChartSetString(prevChart,CHART_EXPERT_NAME,"drawtl");
      //if(!res) GetLastError();
      //ChartRedraw(prevChart);
      double Ask = SymbolInfoDouble(ChartSymbol(prevChart),SYMBOL_ASK);
      double Bid = SymbolInfoDouble(ChartSymbol(prevChart),SYMBOL_BID);
      double Spread = SymbolInfoInteger(ChartSymbol(prevChart),SYMBOL_SPREAD);
      string comment=StringFormat("Ask = %G  Bid = %G  Spread = %d",Ask,Bid,Spread); 
      //string eaname = "drawtl";
      ChartSetString(prevChart,CHART_COMMENT,comment);
      //ChartSetString(prevChart,CHART_EXPERT_NAME,eaname);
      currChart=ChartNext(prevChart); // 通过使用之前图表ID获得新图表ID 
      if(currChart<0) break;          // 到达了图表列表末端 
      //Print(i,ChartSymbol(currChart)," ID =",currChart); 
      prevChart=currChart;// 为ChartNext()保存当前图表ID 
      i++;// 不要忘记增加计数器 
     }
  }
//+------------------------------------------------------------------+
