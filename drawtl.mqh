
#include <Arrays\ArrayInt.mqh> 
#include <Arrays\ArrayDouble.mqh>
class TL 
{ 
	private: 
	   int               barsnum_M1;           
	   double            High_M1[];
	   double            Low_M1[]; 
	   datetime          Time_M1[];
	   int               FindPoint(int Bar_1,int Bar_Fin,int Trend);
	   CArrayInt tl_arr_up,tl_arr_down;//tl_up 储存向上通路节点序列号,TL_DOWN存储向下通路序列号
	   CArrayInt temp_up,temp_down;
	   int               get_tl_width_bar(int bar1,int bar2,double x1,double x2,string direct);//计算两个序列号之间通道最宽的序列号
      struct TL_Points
      {
         CArrayInt   up;
         CArrayInt   down;//把间隔12根K线以内的过滤掉
         //CArrayDouble  up_wth;
         //CArrayDouble  down_wth;
         double      up_wth[];
         double      down_wth[];
         int         big_tl_index;
         string      big_tl_direct;
      };
      struct zig_data
      {
         double zig1;
         double zig2;
         int pos1;
         int pos2;
         double zigArr[];
         int posArr[100];
      };
       bool isChanged(TL_Points &tlp);
       void  cal_bigtl(TL_Points &tlp);
	public: 
	   //--- 缺省构造函数 
						 TL(){}; 
	   //--- 参数构造函数 
						 ~TL(){}; 
						 
		bool              draw_tl(TL_Points &tlp);
      int               cac_zig(ENUM_TIMEFRAMES period,zig_data &zig);
      int               iHighest(const double &array[],int depth,int startPos);
      int               iLowest(const double &array[],int depth,int startPos); 
      double            getLow(ENUM_TIMEFRAMES period,int index);
      double            getHigh(ENUM_TIMEFRAMES period,int index);
      datetime          getTime(ENUM_TIMEFRAMES period,int index);
      bool              isBreak(TL_Points &tlp,int i,string direct);
};

bool TL::isBreak(TL_Points &tlp,int i,string direct)
{
   bool res = false;
   if(direct == "down")
   {
      double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double trend_Value=ObjectGetValueByTime(0,"down"+i,TimeCurrent(),0);
      if(bid < trend_Value - tlp.down_wth[i]) res = true;
   }
   if(direct == "up")
   {
      double ask = SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double trend_Value=ObjectGetValueByTime(0,"up"+i,TimeCurrent(),0);
      if(ask > trend_Value + tlp.up_wth[i]) res = true;
   }
   return res;

}
double TL::getLow(ENUM_TIMEFRAMES period,int index)
{
   int bar = Bars(_Symbol,period);
   double low[1];
   CopyLow(_Symbol,period,bar - index,1,low);
   return low[0];
}
double TL::getHigh(ENUM_TIMEFRAMES period,int index)
{
   int bar = Bars(_Symbol,period);
   double high[1];
   CopyHigh(_Symbol,period,bar - index,1,high);
   return high[0];
}

datetime TL::getTime(ENUM_TIMEFRAMES period,int index)
{
   int bar = Bars(_Symbol,period);
   datetime time[1];
   CopyTime(_Symbol,period,bar - index,1,time);
   return time[0];
}

void TL::cal_bigtl(TL_Points &tlp)
{

   zig_data z;
   cac_zig(PERIOD_H4,z);
   tlp.big_tl_direct = NULL;
   if(z.zig1 < z.zig2)
   {
      double temp = z.zig2 - z.zig1;
      //int i = tlp.down.Total()-2;
      //if(!isBreak(tlp,i,"down"))
      //{
      //   tlp.big_tl_direct = "down";
      //   tlp.big_tl_index = i;
      //   ObjectSetInteger(0,"down"+i,OBJPROP_WIDTH,5);
      //}else 
      //{
      //   tlp.big_tl_direct = NULL;
      //   ObjectSetInteger(0,"down"+i,OBJPROP_WIDTH,0);
      //}

      for(int i = tlp.down.Total()-2 ;i >= 0;i--)
      {
         bool cond1 = (getHigh(PERIOD_M1,tlp.down[i]) > z.zig2 - temp/6) && getTime(PERIOD_M1,tlp.down[i]) > getTime(PERIOD_H4,z.pos2-1);
         bool cond2 = isBreak(tlp,i,"down");
         if(cond1 && !cond2) 
         {
            tlp.big_tl_direct = "down";
            tlp.big_tl_index = i;
         }
      }
      if(tlp.big_tl_direct != "down")
      {
        for(int i=0;i<= tlp.down.Total()-2;i++)
        {
            bool cond1 = getTime(PERIOD_M1,tlp.down[i]) < getTime(PERIOD_H4,z.pos2-1);
            bool cond2 = isBreak(tlp,i,"down");
            if(cond1 && cond2)
            {
               tlp.big_tl_direct = "down";
               tlp.big_tl_index = i;
               return;
            }
        }
      }
      if(tlp.big_tl_direct != "down")
      {
         if(tlp.down.Total()>0)
         {
            tlp.big_tl_direct = "down";
            tlp.big_tl_index = tlp.down.Total()-2;

         }
      }
      ObjectSetInteger(0,"down"+tlp.big_tl_index,OBJPROP_WIDTH,5);
   }else
   {
      //int i = tlp.up.Total()-2;
      //if(!isBreak(tlp,tlp.up.Total()-2,"up"))
      //{
      //   tlp.big_tl_direct = "up";
      //   tlp.big_tl_index = i;
      //   ObjectSetInteger(0,"up"+i,OBJPROP_WIDTH,5);
      //}else 
      //{
      //   tlp.big_tl_direct = NULL;
      //   ObjectSetInteger(0,"up"+i,OBJPROP_WIDTH,0);
      //}
      double temp = z.zig1 - z.zig2;
      for(int i = tlp.up.Total()-2 ;i >= 0;i--)
      {
         bool cond1 = (getLow(PERIOD_M1,tlp.up[i]) < z.zig2 + temp/6) && getTime(PERIOD_M1,tlp.up[i]) > getTime(PERIOD_H4,z.pos2-1);
         bool cond2 = isBreak(tlp,i,"up");
         if(cond1 && !cond2) 
         {
            tlp.big_tl_direct = "up";
            tlp.big_tl_index = i;
         }
      }
      if(tlp.big_tl_direct != "up")
      {
        for(int i=0;i<= tlp.up.Total()-2;i++)
        {
            bool cond1 = getTime(PERIOD_M1,tlp.up[i]) < getTime(PERIOD_H4,z.pos2-1);
            bool cond2 = isBreak(tlp,i,"up");
            if(cond1 && cond2)
            {
               tlp.big_tl_direct = "up";
               tlp.big_tl_index = i;
               return;
            }
        }
      }
      if(tlp.big_tl_direct != "up")
      {
         if(tlp.up.Total()>0)
         {
            tlp.big_tl_direct = "up";
            tlp.big_tl_index = tlp.up.Total()-2;

         }
      }
      ObjectSetInteger(0,"up"+tlp.big_tl_index,OBJPROP_WIDTH,5);
   }
}

bool TL::draw_tl(TL_Points &tlp)
{
     static datetime PrevBars=0;
     datetime time_0=iTime(_Symbol,PERIOD_M1,0);
     if(time_0==PrevBars)      return false;
     PrevBars=time_0;
      
     tlp.up.Clear();
     tlp.down.Clear();
     tl_arr_down.Clear();
     tl_arr_up.Clear();
     //tlp.up_wth.Clear();
     //tlp.down_wth.Clear();
     //ArrayInitialize(tlp.down_wth,0);
     //ArrayInitialize(tlp.up_wth,0);
     barsnum_M1=Bars(_Symbol,PERIOD_M1);       
     CopyHigh(_Symbol,PERIOD_M1,0,barsnum_M1,High_M1);
     CopyLow(_Symbol,PERIOD_M1,0,barsnum_M1,Low_M1);
     CopyTime(_Symbol,PERIOD_M1,0,barsnum_M1,Time_M1);
     int temp_index_up,temp_index_down;
     tl_arr_up.Add(barsnum_M1);
     tl_arr_down.Add(barsnum_M1);
     for(int i=barsnum_M1-2;;i--)//蓝线起始尾部处理
     {
         if(Low_M1[i]>Low_M1[i-1])
         {
            temp_index_up = i - 1;
            break;
         }
     }
     for(int i=barsnum_M1-2;;i--)//红线起始尾部处理
     {
         if(High_M1[i]<High_M1[i-1])
         {
            temp_index_down = i - 1;
            break;
         }
     }

     while(temp_index_up < tl_arr_up[tl_arr_up.Total() -1])// && temp_index_up < barsnum_M1-3000
     {
         tl_arr_up.Add(temp_index_up);
         temp_index_up = FindPoint(temp_index_up,barsnum_M1-3000,1);
     }
     while(temp_index_down < tl_arr_down[tl_arr_down.Total() -1])// && temp_index_down < barsnum_M1-3000
     {
         tl_arr_down.Add(temp_index_down);
         temp_index_down = FindPoint(temp_index_down,barsnum_M1-3000,-1);
     }
     
     
     tl_arr_up.Delete(0);//把第一次放入的数据（用于while循环的第一次）剔除
     tl_arr_down.Delete(0);
     for(int i = 1;i<= tl_arr_up.Total()-1;i++)
     {
         if(tl_arr_up[i-1] -tl_arr_up[i] > 12 && tlp.up.Total() == 0) //如果第一次K线间隔<12就剔除第一个点
         {
            tlp.up.Add(tl_arr_up[i-1]);
            tlp.up.Add(tl_arr_up[i]);
         } 
         if(tlp.up.Total() > 0 && tlp.up[tlp.up.Total() -1] - tl_arr_up[i]  > 12)//如果已经有数据，K线间隔<12就剔除后面的点
         {
            tlp.up.Add(tl_arr_up[i]);
         }
     }
      for(int i = 1;i<= tl_arr_down.Total()-1;i++)
     {
         if(tl_arr_down[i-1] -tl_arr_down[i] > 12 && tlp.down.Total() == 0)
         {
            tlp.down.Add(tl_arr_down[i-1]);
            tlp.down.Add(tl_arr_down[i]);
         } 
         if(tlp.down.Total() > 0 && tlp.down[tlp.down.Total() -1] - tl_arr_down[i]  > 12)
         {
            tlp.down.Add(tl_arr_down[i]);
         }
     }
     

     
   //上面代码获取绘图点并删除间隔小于12根K线的点,下面的代码开始画趋势线 
   if(isChanged(tlp))
   {
      ObjectsDeleteAll(0,0,OBJ_TREND);
   }else return false; 
    
   //ObjectsDeleteAll(0,0,OBJ_TREND);
   for(int i = tlp.up.Total()-2 ;i >= 0;i--)
   {
      ArrayResize(tlp.up_wth,tlp.up.Total()-1);
      datetime t1 = Time_M1[tlp.up[i+1]];
      datetime t2 = Time_M1[tlp.up[i]];
      double x1 = Low_M1[tlp.up[i+1]];
      double x2 = Low_M1[tlp.up[i]]; 
      if(!ObjectCreate(0,"up"+i,OBJ_TREND,0,t1,x1,t2,x2))return(false);
      ObjectSetInteger(0,"up"+i,OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(0,"up"+i,OBJPROP_RAY_RIGHT,true);
      int bar_width = get_tl_width_bar(tlp.up[i+1],tlp.up[i],x1,x2,"tl_up");
      double bar_width_Value=ObjectGetValueByTime(0,"up"+i,Time_M1[bar_width],0);
      //tlp.up_wth.Add(High_M1[bar_width]-bar_width_Value);
      tlp.up_wth[i] = High_M1[bar_width]-bar_width_Value;
      double Bar0_Value=x1+(High_M1[bar_width]-bar_width_Value);
      double Bar1_Value=x2+(High_M1[bar_width]-bar_width_Value);
      if(!ObjectCreate(0,"up_dot"+i,OBJ_TREND,0,t1,Bar0_Value,t2,Bar1_Value))return(false);
      ObjectSetInteger(0,"up_dot"+i,OBJPROP_COLOR,clrBlue);
      ObjectSetInteger(0,"up_dot"+i,OBJPROP_STYLE,STYLE_DASH);
   }
   for(int i = tlp.down.Total()-2 ;i >= 0;i--)
   {  
      ArrayResize(tlp.down_wth,tlp.down.Total()-1);
      datetime t1 = Time_M1[tlp.down[i+1]];
      datetime t2 = Time_M1[tlp.down[i]];
      double x1 = High_M1[tlp.down[i+1]];
      double x2 = High_M1[tlp.down[i]];
      if(!ObjectCreate(0,"down"+i,OBJ_TREND,0,t1,x1,t2,x2))return(false);
      ObjectSetInteger(0,"down"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"down"+i,OBJPROP_RAY_RIGHT,true);
      int bar_width = get_tl_width_bar(tlp.down[i+1],tlp.down[i],x1,x2,"tl_down");
      double bar_width_Value=ObjectGetValueByTime(0,"down"+i,Time_M1[bar_width],0);
      //tlp.down_wth.Add(bar_width_Value - Low_M1[bar_width]);
      tlp.down_wth[i] = bar_width_Value - Low_M1[bar_width];
      double Bar0_Value=x1-(bar_width_Value-Low_M1[bar_width]);
      double Bar1_Value=x2-(bar_width_Value-Low_M1[bar_width]);
      if(!ObjectCreate(0,"down_dot"+i,OBJ_TREND,0,t1,Bar0_Value,t2,Bar1_Value))return(false);
      ObjectSetInteger(0,"down_dot"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"down_dot"+i,OBJPROP_STYLE,STYLE_DASH);
   }
   
   //找出大通路
   cal_bigtl(tlp);
   return true;
}
bool TL::isChanged(TL_Points &tlp)
{
     bool res = false;
     if(temp_down.Total() != tlp.down.Total()) //如果数量发生变化，就重新赋值
     {
       temp_down.Clear();
       for(int i = 0;i < tlp.down.Total();i++)
       {
         temp_down.Add(tlp.down[i]);
       }
       return true;
     }else
     {
       for(int i = 0;i < tlp.down.Total();i++)
       {
         if(temp_down[i] != tlp.down[i]) //数量未变化，但值发生改变也要重新赋值
         {
             res = true;
             temp_down.Clear();
             for(int i = 0;i < tlp.down.Total();i++)
             {
               temp_down.Add(tlp.down[i]);
             }
              break;
         }
       }
     }
     if(temp_up.Total() != tlp.up.Total()) //如果数量发生变化，就重新赋值
     {
       temp_up.Clear();
       for(int i = 0;i < tlp.up.Total();i++)
       {
         temp_up.Add(tlp.up[i]);
       }
       return true;
     }else
     {
       for(int i = 0;i < tlp.up.Total();i++)
       {
         if(temp_up[i] != tlp.up[i]) //数量未变化，但值发生改变也要重新赋值
         {
             res = true;
             temp_up.Clear();
             for(int i = 0;i < tlp.up.Total();i++)
             {
               temp_up.Add(tlp.up[i]);
             }
              break;
         }
       }
     }
     return res;
}

int TL::FindPoint(int Bar_1,int Bar_Fin,int Trend)
{
    int Bar_2,
        i;
    double BarValue_1,
           BarValue_2,
           BarValue_i;
    Bar_2=Bar_1;
    for(i=Bar_1-1;i>Bar_Fin;i--)
    {
        if(Trend==1)
        {
           if(Low_M1[i]<Low_M1[Bar_1])
           {
              Bar_2=i;
              break;
           }
        }
        else
        {
            if(High_M1[i]>High_M1[Bar_1])
            {
               Bar_2=i;
               break;
            }
        }
    }
    if(Bar_2<Bar_1)
    {
       int MaxBar=Bar_2;
       double LineFirst;
       if(Trend==1)
       {
          LineFirst=(Low_M1[Bar_1]-Low_M1[Bar_2])/(Bar_1-Bar_2);
          for(i=MaxBar-1;i>0;i--)
          {
              if(Low_M1[i] > Low_M1[Bar_2]) continue; //update
              if((Low_M1[Bar_1]-Low_M1[i])/(Bar_1-i)>LineFirst)
              {
                 Bar_2=i;
                 LineFirst=(Low_M1[Bar_1]-Low_M1[Bar_2])/(Bar_1-Bar_2);
              }
          }
       }
       else
       {
           LineFirst=(High_M1[Bar_2]-High_M1[Bar_1])/(Bar_1-Bar_2);
           for(i=MaxBar-1;i>0;i--)
           {
               if(High_M1[i] < High_M1[Bar_2]) continue;//update
               if((High_M1[i]-High_M1[Bar_1])/(Bar_1-i)>LineFirst)
               {
                  Bar_2=i;
                  LineFirst=(High_M1[Bar_2]-High_M1[Bar_1])/(Bar_1-Bar_2);
               }
           }
       }
    }
    return(Bar_2);
}


int TL::get_tl_width_bar(int bar1,int bar2,double x1,double x2,string direct)//计算两个序列号之间通道最宽的序列号
{
   double temp_width = 0.0;
   int bar_width = 0;
   if(direct == "tl_up")
   {
      for(int i = bar1+1; i < bar2;i++)
      {
         double width = High_M1[i] - (x2 - x1)*(bar1-i)/(bar1 - bar2) - x1;
         if(width > temp_width)
         {
            temp_width = width;
            bar_width = i;
         } 
      }
   }
   if(direct == "tl_down")
   {
      for(int i = bar1+1; i < bar2;i++)
      {
         double width = x2 + (x1 - x2)*(i - bar2)/(bar1 - bar2)  - Low_M1[i];
         if(width > temp_width)
         {
            temp_width = width;
            bar_width = i;
         } 
      }
   }
   //double diff = price_highest - (x1_solid+(x2_solid - x1_solid)*(tl_up_arr[i+1] - highest_index)/(tl_up_arr[i+1]-tl_up_arr[i]));
   return bar_width;
   
}

int TL::iHighest(const double &array[],int depth,int startPos)
{
    int index=startPos;
    if(startPos<0)
    {
       return 0;
    }
    int size=ArraySize(array);
    if(startPos-depth<0)depth=startPos;
    double max=array[startPos];
    int i;
    for(i=startPos;i>startPos-depth;i--)
    {
        if(array[i]>max)
        {
           index=i;
           max=array[i];
        }
    }
    return(index);
}

//+------------------------------------------------------------------+
//|  寻找12根柱的最低点                                              |
//+------------------------------------------------------------------+
int TL::iLowest(const double &array[],int depth,int startPos)
{
    int index=startPos;
    if(startPos<0)
    {
       return 0;
    }
    int size=ArraySize(array);
    if(startPos-depth<0)depth=startPos;
    double min=array[startPos];
    int i;
    for(i=startPos;i>startPos-depth;i--)
    {
        if(array[i]<min)
        {
           index=i;
           min=array[i];
        }
    }
    return(index);
}
int TL::cac_zig(ENUM_TIMEFRAMES period,zig_data &zig) //zig_store中[0]是第一个极值,[1]是第二个极值,[2]是第一个极值的位置，[3]是第二个极值的位置，使用[2],[3]的时候要用int()强制转换
{
    double deviation=5*_Point;
    int start = 500;
    int ZigZagBuffer_num;
    double High[],Low[],HighMapBuffer[],LowMapBuffer[];
    datetime Time[];
    int barsnum = Bars(_Symbol,period);
    CopyHigh(_Symbol,period,0,barsnum,High);
    CopyLow(_Symbol,period,0,barsnum,Low);
    CopyTime(_Symbol,period,0,barsnum,Time);
    int i=0,limit=barsnum-start,shift=0;
    int counterZ=0;
    int level=3;
    int whatlookfor=0;
    int lasthighpos=0,lastlowpos=0;
    double curhigh=0,curlow=0,lasthigh=0,lastlow=0;
    double val=0,res=0;
    int back=0;
    ArrayResize(zig.zigArr,barsnum);
    ArrayResize(LowMapBuffer,barsnum);
    ArrayResize(HighMapBuffer,barsnum);
    ArrayInitialize(zig.zigArr,0);
    ArrayInitialize(LowMapBuffer,0);
    ArrayInitialize(HighMapBuffer,0);
     for(shift=limit;shift<barsnum;shift++)
     {
         //寻找低点
         val=Low[iLowest(Low,12,shift)];
         if(val==lastlow)val=0.0;
         else
         {
             lastlow=val;
             if(Low[shift]-val>deviation)val=0.0;
             else
             {
                 for(back=1;back<=3;back++)
                 {
                     res=LowMapBuffer[shift-back];
                     if((res!=0)&&(res>val))LowMapBuffer[shift-back]=0.0;
                 }
             }
         }
         if(Low[shift]==val)LowMapBuffer[shift]=val;
         else LowMapBuffer[shift]=0.0;
         //寻找高点
         val=High[iHighest(High,12,shift)];
         if(val==lasthigh)val=0.0;
         else
         {
             lasthigh=val;
             if(val-High[shift]>deviation)val=0.0;
             else
             {
                 for(back=1;back<=3;back++)
                 {
                     res=HighMapBuffer[shift-back];
                     if((res!=0)&&(res<val))HighMapBuffer[shift-back]=0.0;
                 }
             }
         } 
         if(High[shift]==val)HighMapBuffer[shift]=val;
         else HighMapBuffer[shift]=0.0;
     }
     if(whatlookfor==0)
     {
        lastlow=0;
        lasthigh=0;
     }
     else
     {
         lastlow=curlow;
         lasthigh=curhigh;
     }
     for(shift=limit;shift<barsnum;shift++)
     {
         res=0.0;
         switch(whatlookfor)
         {
                case 0:
                       if((lastlow==0)&&(lasthigh==0))
                       {
                          if(HighMapBuffer[shift]!=0)
                          {
                             lasthigh=High[shift];
                             lasthighpos=shift;
                             whatlookfor=-1;
                             zig.zigArr[shift]=lasthigh;
                             res=1;
                          }
                          if(LowMapBuffer[shift]!=0)
                          {
                             lastlow=Low[shift];
                             lastlowpos=shift;
                             whatlookfor=1;
                             zig.zigArr[shift]=lastlow;
                             res=1;
                          }
                       }
                       break;
                case 1:
                       if((LowMapBuffer[shift]!=0.0)&&(LowMapBuffer[shift]<lastlow)&&(HighMapBuffer[shift]==0.0))
                       {
                          zig.zigArr[lastlowpos]=0.0;
                          lastlowpos=shift;
                          lastlow=LowMapBuffer[shift];
                          zig.zigArr[shift]=lastlow;
                          res=1;
                       }
                       if((HighMapBuffer[shift]!=0.0)&&(LowMapBuffer[shift]==0.0))
                       {
                          lasthigh=HighMapBuffer[shift];
                          lasthighpos=shift;
                          zig.zigArr[shift]=lasthigh;
                          whatlookfor=-1;
                          res=1;
                       }
                       break;
                case -1:
                       if((HighMapBuffer[shift]!=0.0)&&(HighMapBuffer[shift]>lasthigh)&&(LowMapBuffer[shift]==0.0))
                       {
                          zig.zigArr[lasthighpos]=0.0;
                          lasthighpos=shift;
                          lasthigh=HighMapBuffer[shift];
                          zig.zigArr[shift]=lasthigh;
                          res=1;
                       }
                       if((LowMapBuffer[shift]!=0.0)&&(HighMapBuffer[shift]==0.0))
                       {
                          lastlow=LowMapBuffer[shift];
                          lastlowpos=shift;
                          zig.zigArr[shift]=lastlow;
                          whatlookfor=1;
                          res=1;
                       }
                       break;
                 default: return(0);
         }
     }
     ZigZagBuffer_num=0;
      for(i=barsnum-1;i>=barsnum-start;i--)
      {
          if(zig.zigArr[i]!=0.0)
          {
             ZigZagBuffer_num++;
             zig.posArr[ZigZagBuffer_num]=i;
          }
      }
      zig.zig1 = zig.zigArr[zig.posArr[1]];
      zig.zig2 = zig.zigArr[zig.posArr[2]];
      zig.pos1 = zig.posArr[1]+1;
      zig.pos2 = zig.posArr[2]+1;
     return 0;
}