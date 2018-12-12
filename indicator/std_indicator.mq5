#property copyright "Copyright 2011, MetaQuotes Software Corp." 
#property link      "https://www.mql5.com" 
#property version   "1.00" 

  
#property indicator_separate_window 
#property indicator_buffers 1 
#property indicator_plots   1 
//--- iStdDev 标图 
#property indicator_label1  "iRatio" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrMediumSeaGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//+------------------------------------------------------------------+ 
//| 枚举处理创建方法                                                   | 
//+------------------------------------------------------------------+ 

//--- 输入参数 
input int                  CAL_COUNT=200;                // 移动 
input int                  ma_period=30;              // 平均周期 
input int                  ma_shift=0;                // 移动 
input ENUM_MA_METHOD       ma_method=MODE_SMA;        // 平滑类型 
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // 价格类型   
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;     // 时间帧 
//--- 指标缓冲区 

double ratio[];
//--- 存储 iStdDev 指标处理程序的变量 
int    handleStd,handleMa; 
//--- 存储变量 

//--- 图表上的指标名称 
string short_name; 
//--- 我们将在标准偏差指标中保持值的数量 
int    bars_calculated=0; 
//+------------------------------------------------------------------+ 
//| 自定义指标初始化函数                                                | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
   ArraySetAsSeries(ratio,true);
   SetIndexBuffer(0,ratio,INDICATOR_DATA); 
//--- 设置移动 
   PlotIndexSetInteger(0,PLOT_SHIFT,ma_shift); 

//--- 创建指标处理程序 
   
      handleStd=iStdDev(_Symbol,period,ma_period,ma_shift,ma_method,applied_price); 
      handleMa=iMA(_Symbol,period,ma_period,ma_shift,ma_method,applied_price); 
//--- 如果没有创建处理程序 
   if(handleMa==INVALID_HANDLE) 
     { 
      //--- 叙述失败和输出错误代码 
      PrintFormat("Failed to create handle of the iStdDev indicator for the symbol %s/%s, error code %d", 
                  _Symbol, 
                  EnumToString(period), 
                  GetLastError()); 
      //--- 指标提前停止 
      return(INIT_FAILED); 
     } 
//--- 显示标准偏差指标计算的交易品种/时间帧 
   short_name=StringFormat("iStdDev(%s/%s, %d, %d, %s, %s)",_Symbol,EnumToString(period), 
                           ma_period,ma_shift,EnumToString(ma_method),EnumToString(applied_price)); 
   IndicatorSetString(INDICATOR_SHORTNAME,short_name); 
//--- 指标正常初始化   
   return(INIT_SUCCEEDED); 
  } 
//+------------------------------------------------------------------+ 
//| 自定义指标迭代函数                                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const datetime &time[], 
                const double &open[], 
                const double &high[], 
                const double &low[], 
                const double &close[], 
                const long &tick_volume[], 
                const long &volume[], 
                const int &spread[]) 
  { 
//--- 从iStdDev指标复制的值数 
   int values_to_copy; 
//--- 确定指标计算的数量值 
   int calculated=BarsCalculated(handleMa); 
   if(calculated<=0) 
     { 
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError()); 
      return(0); 
     } 
//--- 如果它是指标计算的最初起点或如果iStdDev指标数量值更改 
//--- 或如果需要计算两个或多个柱形的指标（这意味着价格历史中有些内容会发生变化） 
   if(prev_calculated>0) 
     { 
         double         iStdDevBuffer[]; 
         double         iMaBuffer[];
         double         close[]; 
         ArraySetAsSeries(iStdDevBuffer,true);
         ArraySetAsSeries(iMaBuffer,true);
         ArraySetAsSeries(close,true);
      //--- 以0标引指标缓冲区的值填充部分iStdDevBuffer数组 
         CopyBuffer(handleStd,0,0,CAL_COUNT,iStdDevBuffer);
         CopyBuffer(handleMa,0,0,CAL_COUNT,iMaBuffer);
         CopyClose(_Symbol,period,0,CAL_COUNT,close);
         for(int i = 0;i < CAL_COUNT;i++)
         {
            if(iStdDevBuffer[i] <=0) return false;
            ArrayResize(ratio,i+1);
            ratio[i] =   (close[i] - iMaBuffer[i])/iStdDevBuffer[i];
         }
     } 

     //values_to_copy = (values_to_copy > CAL_COUNT)?CAL_COUNT:values_to_copy;
//--- 以标准偏差指标的值填充数组 
//--- 如果FillArrayFromBuffer 返回 false，它表示信息还未准备，退出操作 
   //if(!FillArrayFromBuffer(ratio,ma_shift,handleStd,handleMa,values_to_copy)) return(0); 
//--- 形成信息 
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d", 
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS), 
                            short_name, 
                            values_to_copy); 
//--- 在图表上展示服务信息 
   Comment(comm); 
//--- 记住标准偏差指标的数量值 
   bars_calculated=calculated; 
//--- 返回prev_calculated值以便下次调用 
   return(rates_total); 
  } 
//+------------------------------------------------------------------+ 
//| 填充iStdDev指标的指标缓冲区                                         | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &ratio_buffer[],  // 标准偏差线的指标缓冲区 
                         int std_shift,         // 标准偏差线的移动 
                         int std_handle,        // iStdDev 指标的处理程序 
                         int ma_handle,
                         int amount             // 复制值的数量 
                         ) 
  { 
//--- 重置错误代码 
   ResetLastError();
   double         iStdDevBuffer[]; 
   double         iMaBuffer[];
   double         close[]; 
   ArrayInitialize(close,0.0);
   ArraySetAsSeries(iStdDevBuffer,true);
   ArraySetAsSeries(iMaBuffer,true);
   ArraySetAsSeries(close,true);
//--- 以0标引指标缓冲区的值填充部分iStdDevBuffer数组 
   CopyBuffer(std_handle,0,0,amount,iStdDevBuffer);
   CopyBuffer(ma_handle,0,0,amount,iMaBuffer);
   CopyClose(_Symbol,period,0,amount,close);
   for(int i = 0;i < amount;i++)
   {
      if(iStdDevBuffer[i] <=0) return false;
      ArrayResize(ratio_buffer,i+1);
      ratio_buffer[i] =   (close[i] - iMaBuffer[i])/iStdDevBuffer[i];
   }
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| 指标去初始化函数                                                   | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//--- 删除指标后清空图表 
   Comment(""); 
  }