//+------------------------------------------------------------------+
//|                                                      AMATAEA.mq4 |
//|                                                    Nampee Ponpth |
//|                                              nampee003@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Nampee Ponpth"
#property link      "https://amataverse.blogspot.com"
#property version   "1.000"
//--------------------------------------------------------------------
#include <stderror.mqh>
#include <stdlib.mqh>
string URL = "https://script.google.com/macros/s/AKfycby5g2Ylun33qBL2VeUbWEE4NVQTgxSPkfXll3OiMtw14TN0d_QWRizoSgYUddAeUp3Yow/exec";
input  int    Magic        = 8;         //EA identification number to identify trades.
int    ChartRank           = 1;
int    ChartsTotal         = 1;
string CanceledSymbol      = "";
int    TimerSec            = 1;
input  ENUM_TIMEFRAMES     BigTrendTimeFrame         = 1440;
input  int                 BigTrendMAperiod          = 5;
input  int                 MainMAperiod              = 30;
input  ENUM_TIMEFRAMES     TimeFrame                 = 15;
input  int                 SubMAperiod               = 25;
input  int                 MA_Shift                  = 0;           // MA Shift
input  ENUM_MA_METHOD      MA_method                 = MODE_SMMA;   // MA method
input  ENUM_APPLIED_PRICE  MA_price                  = PRICE_CLOSE; // MA price
input  int                 SideWayBar1               = 10;
input  int                 SideWaySlope1             = 1;
input  int                 SideWayBar2               = 200;
input  int                 SideWaySlope2             = 1;
input  int                 SideWayBar3               = 450;
input  int                 SideWaySlope3             = 1;
input  int                 SideWayBar4               = 650;
input  int                 SideWaySlope4             = 1;
input  int                 SideWayBar5               = 800;
input  int                 SideWaySlope5             = 1;
extern int                 adxperiod                 = 3;
extern int                 adxLevel                  = 30;
extern int                 DIgab                     = 0;
input  int                 ATRperiod                 = 10;
input  double              ATRlevel                  = 0;
bool   SnowBall            = true;
bool   Martingale          = true;
input  double              ProfitTrail               = 0;
input  double              TrailMinProfit            = 5;
input  double              StopLoss                  = 0;
bool   CloseLossType       = false;
extern double              SnOrderStep               = 5;
extern double              MaOrderStep               = 5;
input  int                 HedgeOrders               = 5;
double fastOrderStep       = 0;
double StepX               = 0;
extern double              LotX                      = 1.2;
input  double              TargetProfitPercent       = 2;
extern double              TakeTypeProfit            = 0;
extern double              TakeSymProfit             = 1;
input  bool                AutoIncreaseTakeSymProfit = true;
double SymStopLoss         = 0;
double MartingaleMultiplier= 0;
double CloseMagicProfitPC  = 0;
double BaseProfit          = 0;
double EquityTrail         = 0;
input  bool                FixBaseBalance            = true;
extern double              BaseBalance               = 500;
extern double              Deposit                   = 500;
extern double              LimitLoss                 = 0;
extern double              LimitBalance              = 1500000;
input  int                 RiskOrders                = 0;
input  int                 RiskMarginLevel           = 10000;
int    BoostOrders         = 0;
double BoostX              = 0;
input  int                 MaxOrder                  = 1000;
input  int                 LimitSpread               = 30;
input  int                 DayToPause                = 0;
input  int                 SartQuotesHour            = 1;
int    SaftMarginLevel     = 0;
int    SaftEquity          = 0;
int    minMarginLevel      = 0;
int    MaxDrawDownPercent  = 0;
double MaxBaseLot          = 10000;
double MaxLot              = 10000;
double HiAccBalance        = 0;
double HiProfitBalance     = 0;
double LowMarginLevel      = 9999999999;

int       digit1,spread1,stoplev1,mm,TakeProfit1,k,nn,mmx,trade,HiTotal,HiSpread,replace,accLeverage,accStopoutLevel,HiOrderRange;
double    ask1,bid1,point1,LotStep1,maxLot1,minLot1,TurnPrice,HiOrderProfit,LowAcProfitPercent,StartEquity,
          Lots,highest,HiAccbalance,HiAccBalance1,HiLots2,HiOrderLots,TodayHiProp,TodayProfit,TodayMaxDD,DaysMaxDD,accBalance,accEquity,accFreeMargin,accProfit;
datetime  LastBuyOT,LastSelOT,LastBuyOT1,LastSelOT1,LastMagicOrderCloseTime;
string    url,accNumber,accServer,accCompany,accName,expertName="AmataEA",onscreen;
bool      StopLossBuy,StopLossSel,BreakEven_Buy,BreakEven_Sell;
//============================================================================================================================================
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//Lock Account =====================================================================*/
   if(AccountNumber()!=1 && !IsDemo() && !IsTesting() && Status()!="allow")
     {
      Comment("Your account status is : ",Status());
      Print("Your account status is : ",Status());
      return(INIT_SUCCEEDED);
     }
//=====================================================================*/
//--- create timer
   EventSetTimer(TimerSec);
//=====================================================================*/
   GlobalVariableSet("TakeMagicProfit",0);
   GlobalVariableSet("MartingaleMultiplier",MartingaleMultiplier);
   GlobalVariableSet("CloseMagicProfitPC",CloseMagicProfitPC);
   GlobalVariableSet("BaseProfit",BaseProfit);
   GlobalVariableSet("EquityTrail",EquityTrail);
   GlobalVariableSet("SaftMarginLevel",SaftMarginLevel);
   GlobalVariableSet("SaftEquity",SaftEquity);
   GlobalVariableSet("minMarginLevel",minMarginLevel);
   GlobalVariableSet("ChartsTotal",ChartsTotal);

   if(HiAccBalance>0)
     {
      GlobalVariableSet("HiAccBL",HiAccBalance);
      HiAccbalance=HiAccBalance;
     }
   else
      if(AccountBalance()+AccountCredit()>=GlobalVariableGet("HiAccBL"))
        {
         GlobalVariableSet("HiAccBL",AccountBalance()+AccountCredit());
         HiAccbalance=AccountBalance()+AccountCredit();
        }

   GlobalVariableSet("LowMarginLevel",LowMarginLevel);

   StartEquity = AccountEquity();

   if(!IsTesting())
     {
      int ReadHiProfitBL_handle = FileOpen(AccountNumber()+"HiProfitBL.csv",FILE_READ);
      double HiProfitBL1 = FileReadNumber(ReadHiProfitBL_handle);
      FileClose(ReadHiProfitBL_handle);

      if(HiProfitBalance>0)
         GlobalVariableSet("HiProfitBL",HiProfitBalance);
      else
         if(HiProfitBL1>0)
            GlobalVariableSet("HiProfitBL",HiProfitBL1);
         else
            GlobalVariableSet("HiProfitBL",AccountBalance()+AccountCredit());

      if(AccountProfit()>=0 && AccountEquity()>GlobalVariableGet("HiProfitBL"))
         GlobalVariableSet("HiProfitBL",AccountEquity());

      GlobalVariableSet("LastHiProfitBL",GlobalVariableGet("HiProfitBL"));

      int ReadLoML_handle = FileOpen(AccountNumber()+"LoML.csv",FILE_READ);
      double LoML = FileReadNumber(ReadLoML_handle);
      FileClose(ReadLoML_handle);
      if(LoML>0)
         GlobalVariableSet("LowMarginLevel",LoML);
      else
         GlobalVariableSet("LowMarginLevel",LowMarginLevel);

      int ReadHiestEq_handle = FileOpen(AccountNumber()+"HiestEquity.csv",FILE_READ);
      double HiestEq = FileReadNumber(ReadHiestEq_handle);
      FileClose(ReadHiestEq_handle);
      if(HiestEq>0)
         GlobalVariableSet("HiestEquity",HiestEq);

      int ReadHiEq_handle = FileOpen(AccountNumber()+"HiEquity.csv",FILE_READ);
      double HiEq = FileReadNumber(ReadHiEq_handle);
      FileClose(ReadHiEq_handle);
      if(HiEq>0)
         GlobalVariableSet("HiEquity",HiEq);

      int ReadSafeBalance_handle = FileOpen(AccountNumber()+Symbol()+"SafeBalance.csv",FILE_READ);
      double SafeBalance1 = FileReadNumber(ReadSafeBalance_handle);
      FileClose(ReadSafeBalance_handle);
      if(SafeBalance1>0)
         LimitBalance = SafeBalance1;

      int ReadHiLots2_handle = FileOpen(AccountNumber()+"HiLots2.csv",FILE_READ);
      HiLots2 = FileReadNumber(ReadHiLots2_handle);
      FileClose(ReadHiLots2_handle);

      int ReadHiOrderLots_handle = FileOpen(AccountNumber()+Symbol()+"HiOrderLots.csv",FILE_READ);
      HiOrderLots = FileReadNumber(ReadHiOrderLots_handle);
      FileClose(ReadHiOrderLots_handle);

      int ReadHiAccbalance_handle = FileOpen(AccountNumber()+"HiAccbalance.csv",FILE_READ);
      HiAccBalance1 = FileReadNumber(ReadHiAccbalance_handle);
      FileClose(ReadHiAccbalance_handle);
     }

   if(HiAccBalance>0)
      HiAccbalance=HiAccBalance;
   else
      HiAccbalance = HiAccBalance1;

   int ReadWon_handle = FileOpen(AccountNumber()+"Won.csv",FILE_READ);
   int Won = FileReadNumber(ReadWon_handle);
   FileClose(ReadWon_handle);
   if(Won>0)
      GlobalVariableSet("won",Won);
//---------------------------------------------------------------------------------------------------------------------------------------------------
//if(AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
// {
//---P LABEL---
   ObjectCreate("P",OBJ_LABEL,0,0,0);
   ObjectSet("P",OBJPROP_CORNER,3);
   ObjectSet("P",OBJPROP_XDISTANCE,10);
   ObjectSet("P",OBJPROP_YDISTANCE,70);
   ObjectSetText("P","Trading is paused and ready to CloseAll",15,"Tahoma",clrRed);
   ObjectSetInteger(0,"P",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"P",OBJPROP_SELECTED,false);
//---Pause BUTTON---
//--- create the button
   ObjectCreate("Pause",OBJ_BUTTON,0,0,0);
//--- set button coordinates
   ObjectSetInteger(0,"Pause",OBJPROP_XDISTANCE,360);
   ObjectSetInteger(0,"Pause",OBJPROP_YDISTANCE,65);
//--- set button size
   ObjectSetInteger(0,"Pause",OBJPROP_XSIZE,190);
   ObjectSetInteger(0,"Pause",OBJPROP_YSIZE,60);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0,"Pause",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
//--- set the text
   ObjectSetString(0,"Pause",OBJPROP_TEXT,"Start");
//--- set text font
   ObjectSetString(0,"Pause",OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(0,"Pause",OBJPROP_FONTSIZE,30);
//--- set text color
   ObjectSetInteger(0,"Pause",OBJPROP_COLOR,clrWhite);
//--- set button state
   ObjectSetInteger(0,"Pause",OBJPROP_STATE,true);
//--- set background color
   ObjectSetInteger(0,"Pause",OBJPROP_BGCOLOR,clrRed);
//--- set border color
//  ObjectSetInteger(0,"CloseAll",OBJPROP_BORDER_COLOR,clrWhiteSmoke);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(0,"Pause",OBJPROP_BACK,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(0,"Pause",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"Pause",OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0,"Pause",OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0,"Pause",OBJPROP_ZORDER,10);
//---CloseAll BUTTON---
//--- create the button
   ObjectCreate("CloseAll",OBJ_BUTTON,0,0,0);
//--- set button coordinates
   ObjectSetInteger(0,"CloseAll",OBJPROP_XDISTANCE,155);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YDISTANCE,65);
//--- set button size
   ObjectSetInteger(0,"CloseAll",OBJPROP_XSIZE,150);
   ObjectSetInteger(0,"CloseAll",OBJPROP_YSIZE,60);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(0,"CloseAll",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
//--- set the text
   ObjectSetString(0,"CloseAll",OBJPROP_TEXT,"CloseAll");
//--- set text font
   ObjectSetString(0,"CloseAll",OBJPROP_FONT,"Arial");
//--- set font size
   ObjectSetInteger(0,"CloseAll",OBJPROP_FONTSIZE,30);
//--- set text color
   ObjectSetInteger(0,"CloseAll",OBJPROP_COLOR,clrWhite);
//--- set button state
   ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
//--- set background color
   ObjectSetInteger(0,"CloseAll",OBJPROP_BGCOLOR,clrRed);
//--- set border color
//  ObjectSetInteger(0,"CloseAll",OBJPROP_BORDER_COLOR,clrWhiteSmoke);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(0,"CloseAll",OBJPROP_BACK,false);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(0,"CloseAll",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"CloseAll",OBJPROP_SELECTED,false);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(0,"CloseAll",OBJPROP_HIDDEN,false);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(0,"CloseAll",OBJPROP_ZORDER,10);
// }
//---------------------------------------------------------------------------------------------------------------------------------------------------
   return(INIT_SUCCEEDED);
  }
//===============================================================================================================================================================
void OnDeinit(const int reason)
  {
   if(!IsTesting())
     {
      int HiProfitBL_handle=FileOpen(AccountNumber()+"HiProfitBL.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiProfitBL_handle,GlobalVariableGet("HiProfitBL"));
      FileClose(HiProfitBL_handle);

      int LoML_handle=FileOpen(AccountNumber()+"LoML.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(LoML_handle,GlobalVariableGet("LowMarginLevel"));
      FileClose(LoML_handle);

      int HiestEq_handle=FileOpen(AccountNumber()+"HiestEquity.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiestEq_handle,GlobalVariableGet("HiestEquity"));
      FileClose(HiestEq_handle);

      int HiEq_handle=FileOpen(AccountNumber()+"HiEquity.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiEq_handle,GlobalVariableGet("HiEquity"));
      FileClose(HiEq_handle);

      int HiLots2_handle=FileOpen(AccountNumber()+"HiLots2.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiLots2_handle,HiLots2);
      FileClose(HiLots2_handle);

      int HiOrderLots_handle=FileOpen(AccountNumber()+Symbol()+"HiOrderLots.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiOrderLots_handle,HiOrderLots);
      FileClose(HiOrderLots_handle);

      int HiAccbalance_handle=FileOpen(AccountNumber()+"HiAccbalance.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(HiAccbalance_handle,HiAccbalance);
      FileClose(HiAccbalance_handle);

      int Won_handle=FileOpen(AccountNumber()+"Won.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(Won_handle,GlobalVariableGet("won"));
      FileClose(Won_handle);

      int SafeBalance_handle=FileOpen(AccountNumber()+Symbol()+"SafeBalance.csv",FILE_SHARE_READ|FILE_WRITE|FILE_CSV);
      FileWrite(SafeBalance_handle,LimitBalance);
      FileClose(SafeBalance_handle);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   ObjectDelete("CloseAll");
   ObjectDelete("P");
   ObjectDelete("Pause");
   ObjectDelete("Risk");
   ObjectDelete("Risk2");
//--- destroy timer
   EventKillTimer();
  }
//===============================================================================================================================================================
void OnTimer()
  {
   TRADE();
  }
//===============================================================================================================================================================
void OnTick()
  {
   TRADE();
  }
//===============================================================================================================================================================
void TRADE()
  {
   if((Hour()==8||Hour()==12||Hour()==16||Hour()==20) && Minute()>=8 && Minute()<=10)
     {
      if(AccountNumber()!=1 && !IsDemo() && !IsTesting() && Status()!="allow")
        {
         Comment("Your account status is : ",Status());
         Print("Your account status is : ",Status());
         return;
        }
     }
//--- set "Trade" button background color
   if(ObjectGetInteger(0,"Trade",OBJPROP_STATE)==false)
     {
      ObjectSetInteger(0,"Trade",OBJPROP_BGCOLOR,clrGoldenrod);
      ObjectSetString(0,"Trade",OBJPROP_TEXT,"In Trend");
     }
   if(ObjectGetInteger(0,"Trade",OBJPROP_STATE)==true)
     {
      ObjectSetInteger(0,"Trade",OBJPROP_BGCOLOR,clrSilver);
      ObjectSetString(0,"Trade",OBJPROP_TEXT,"On Turn");
     }
//--- set "Pause" button background color
   if(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==false)
     {
      ObjectSetInteger(0,"Pause",OBJPROP_BGCOLOR,clrGoldenrod);
      ObjectSetString(0,"Pause",OBJPROP_TEXT,"Pause");
      ObjectSetText("P","EA is Trading.",15,"Tahoma",clrGoldenrod);
     }
   if(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true)
     {
      ObjectSetInteger(0,"Pause",OBJPROP_BGCOLOR,clrRed);
      ObjectSetString(0,"Pause",OBJPROP_TEXT,"Start");
      ObjectSetText("P","Trading is paused and ready to CloseAll",15,"Tahoma",clrRed);
     }
   if(DayToPause>0 && Day()==DayToPause && Hour()==8 && Minute()==0)
      ObjectSetInteger(0,"Pause",OBJPROP_STATE,true);
//--- set "CloseAll" button background color
   if(ObjectGetInteger(0,"CloseAll",OBJPROP_STATE)==false)
      ObjectSetInteger(0,"CloseAll",OBJPROP_BGCOLOR,clrRed);
   if(ObjectGetInteger(0,"CloseAll",OBJPROP_STATE)==true)
      ObjectSetInteger(0,"CloseAll",OBJPROP_BGCOLOR,clrGray);
//============================================================================================================================================
   ask1 = MarketInfo(Symbol(),MODE_ASK);
   bid1 = MarketInfo(Symbol(),MODE_BID);
   digit1 = MarketInfo(Symbol(),MODE_DIGITS);
   point1 = NormalizeDouble(MarketInfo(Symbol(),MODE_POINT),digit1);
   LotStep1 = MarketInfo(Symbol(),MODE_LOTSTEP);
   maxLot1 = MarketInfo(Symbol(),MODE_MAXLOT);
   minLot1 = MarketInfo(Symbol(),MODE_MINLOT);
   spread1 = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   stoplev1= MarketInfo(Symbol(),MODE_STOPLEVEL);
   int contSize = (int)MarketInfo(Symbol(),MODE_LOTSIZE);
   if(contSize>0)
      int contScale= 100000/contSize;
   if(spread1>HiSpread)
      HiSpread = spread1;
//============================================================================================================================================
   if(IsTesting() /*&& StringCompare(StringSubstr(Symbol(),0,3),"BTC",false)==0*/)
     {
      if(AccountMargin()!=0)
        {
         GlobalVariableSet("MarginLevel",NormalizeDouble((AccountEquity()) / AccountMargin() * 100,2));
        }
      else
         if(AccountMargin()==0)
           {
            GlobalVariableSet("MarginLevel",NormalizeDouble((AccountEquity()-AccountCredit())*100*contScale,2));
           }
     }
   else
     {
      if(AccountMargin()!=0)
        {
         GlobalVariableSet("MarginLevel",NormalizeDouble((AccountEquity()) / AccountMargin() * 100,2));
        }
      else
         if(AccountMargin()==0)
           {
            GlobalVariableSet("MarginLevel",NormalizeDouble((AccountEquity()-AccountCredit())*100*contScale,2));
           }
     }
//   if(GlobalVariableGet("MarginLevel")>0 && GlobalVariableGet("LowMarginLevel")<=0)
//      GlobalVariableSet("LowMarginLevel",GlobalVariableGet("MarginLevel"));
   if(GlobalVariableGet("LowMarginLevel") > GlobalVariableGet("MarginLevel"))
      GlobalVariableSet("LowMarginLevel",NormalizeDouble(GlobalVariableGet("MarginLevel"),2));
//---------------------
   int    total,LastTicketB,LastTicketS,B,S,BaseBalance1;
   double BuyProfit,SelProfit,BuyLots,SelLots,AccOpenLot,LastBuyOP,LastSellOP,LastBuyOrderProfit,LastSelOrderProfit,Lots2,Lots3,LastBuyOL,LastSelOL,
          HiOrderOpenPrice,LoOrderOpenPrice=9999999;
   int    LastTicketB1,LastTicketS1,B1,S1;
   double BuyProfit1,SelProfit1,BuyLots1,SelLots1,LastBuyOP1,LastSellOP1,LastBuyOrderProfit1,LastSelOrderProfit1,LastBuyOL1,LastSelOL1,TakeSymProfit1;
//=====================================================================*/
   for(int a=0; a<=OrdersTotal(); a++)
     {
      if(OrderSelect(a, SELECT_BY_POS)==true)
        {
         double LastOpenLot=OrderLots();
         AccOpenLot=AccOpenLot+OrderLots();
         GlobalVariableSet("AccOpenLot",AccOpenLot);
         string LastOpenSym=OrderSymbol();
         int LastOpenOrderType=OrderType();
         if((OrderMagicNumber() == Magic||OrderMagicNumber() == Magic*2) && OrderSymbol()==Symbol())
           {
            total++;
            if(OrderOpenPrice()>HiOrderOpenPrice)
               HiOrderOpenPrice=OrderOpenPrice();
            if(OrderOpenPrice()<LoOrderOpenPrice)
               LoOrderOpenPrice=OrderOpenPrice();
           }
         if(OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_BUY||OrderType()==OP_BUYSTOP))
           {
            LastBuyOP=NormalizeDouble(OrderOpenPrice(),digit1);
            BuyProfit=BuyProfit+OrderProfit()+OrderCommission()+OrderSwap();
            LastTicketB=OrderTicket();
            LastBuyOT=OrderOpenTime();
            BuyLots=BuyLots+OrderLots();
            LastBuyOL=OrderLots();
            LastBuyOrderProfit=OrderProfit();
            B++;
           }
         if(OrderMagicNumber() == Magic && OrderSymbol()==Symbol() && (OrderType()==OP_SELL||OrderType()==OP_SELLSTOP))
           {
            LastSellOP=NormalizeDouble(OrderOpenPrice(),digit1);
            SelProfit=SelProfit+OrderProfit()+OrderCommission()+OrderSwap();
            LastTicketS=OrderTicket();
            LastSelOT=OrderOpenTime();
            SelLots=SelLots+OrderLots();
            LastSelOL=OrderLots();
            LastSelOrderProfit=OrderProfit();
            S++;
           }
         if(OrderMagicNumber() == Magic*2 && OrderSymbol()==Symbol() && (OrderType()==OP_BUY||OrderType()==OP_BUYSTOP))
           {
            LastBuyOP1=NormalizeDouble(OrderOpenPrice(),digit1);
            BuyProfit1=BuyProfit1+OrderProfit()+OrderCommission()+OrderSwap();
            LastTicketB1=OrderTicket();
            LastBuyOT1=OrderOpenTime();
            BuyLots1=BuyLots+OrderLots();
            LastBuyOL1=OrderLots();
            LastBuyOrderProfit1=OrderProfit();
            B1++;
           }
         if(OrderMagicNumber() == Magic*2 && OrderSymbol()==Symbol() && (OrderType()==OP_SELL||OrderType()==OP_SELLSTOP))
           {
            LastSellOP1=NormalizeDouble(OrderOpenPrice(),digit1);
            SelProfit1=SelProfit1+OrderProfit()+OrderCommission()+OrderSwap();
            LastTicketS1=OrderTicket();
            LastSelOT1=OrderOpenTime();
            SelLots1=SelLots+OrderLots();
            LastSelOL1=OrderLots();
            LastSelOrderProfit1=OrderProfit();
            S1++;
           }
        }
     }
///======================================================================
   double CTF_MA        = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,0);
   double SlopeMA1      = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,SideWayBar1);
   double SlopeMA2      = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,SideWayBar2);
   double SlopeMA3      = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,SideWayBar3);
   double SlopeMA4      = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,SideWayBar4);
   double SlopeMA5      = iMA(_Symbol,BigTrendTimeFrame,BigTrendMAperiod,MA_Shift,MA_method,MA_price,SideWayBar5);
   double BigTrendEMA0  = iMA(_Symbol,BigTrendTimeFrame,MainMAperiod,MA_Shift,MA_method,MA_price,0);
   double EMA100s1      = iMA(Symbol(),TimeFrame,SubMAperiod,MA_Shift,MA_method,MA_price,0);
   double EMA5s1        = iMA(Symbol(),TimeFrame,2,MA_Shift,MA_method,MA_price,0);
   int    MAslope1 = (CTF_MA-SlopeMA1)/Point;
   int    MAslope2 = (CTF_MA-SlopeMA2)/Point;
   int    MAslope3 = (CTF_MA-SlopeMA3)/Point;
   int    MAslope4 = (CTF_MA-SlopeMA4)/Point;
   int    MAslope5 = (CTF_MA-SlopeMA5)/Point;

   double adx1  = iADX(Symbol(),TimeFrame,adxperiod,4,0,1);
   double plu1  = iADX(Symbol(),TimeFrame,adxperiod,4,1,1);
   double min1  = iADX(Symbol(),TimeFrame,adxperiod,4,2,1);

   if(ATRlevel>0)
      double ATR0  = iATR(Symbol(),TimeFrame,ATRperiod,0);

   string Trend;
   if(BigTrendEMA0>CTF_MA && ((SideWaySlope1<=0||MAslope1>SideWaySlope1) && (SideWaySlope2<=0||MAslope2>SideWaySlope2) && (SideWaySlope3<=0||MAslope3>SideWaySlope3) && (SideWaySlope4<=0||MAslope4>SideWaySlope4) && (SideWaySlope5<=0||MAslope5>SideWaySlope5)))
      Trend = "Up";
   else
      if(BigTrendEMA0<CTF_MA && ((SideWaySlope1<=0||MAslope1<-SideWaySlope1) && (SideWaySlope2<=0||MAslope2<-SideWaySlope2) && (SideWaySlope3<=0||MAslope3<-SideWaySlope3) && (SideWaySlope4<=0||MAslope4<-SideWaySlope4) && (SideWaySlope5<=0||MAslope5<-SideWaySlope5)))
         Trend = "Down";
      else
         Trend = "Sideway";

   if(adx1<adxLevel)
     {Martingale=true; SnowBall=false;}
   else
     {Martingale=false; SnowBall=true;}

   if(Trend == "Up" && (SubMAperiod<=0||EMA5s1>EMA100s1) && (ATRlevel<=0||ATR0<ATRlevel) // && EMA8s1>EMA13s1 && EMA13s1>EMA50s1 && EMA50s1>EMA100s1 && EMA5s2>EMA8s2 && EMA8s2>EMA13s2 && EMA13s2>EMA50s2 && EMA50s2>EMA100s2
      && (DIgab<=0||plu1>min1+DIgab) //(!(EMA5s3>EMA8s3 && EMA8s3>EMA13s3 && EMA13s3>EMA50s3 && EMA50s3>EMA100s3)&&!(EMA5s4>EMA8s4 && EMA8s4>EMA13s4 && EMA13s4>EMA50s4 && EMA50s4>EMA100s4)&&!(EMA5s5>EMA8s5 && EMA8s5>EMA13s5 && EMA13s5>EMA50s5 && EMA50s5>EMA100s5))
     )
      trade=1;
   else
      if(Trend == "Down" && (SubMAperiod<=0||EMA5s1<EMA100s1) && (ATRlevel<=0||ATR0<ATRlevel) //  //&& EMA5s1<EMA8s1 && EMA8s1<EMA13s1 && EMA13s1<EMA50s1 && EMA50s1<EMA100s1 && EMA5s2<EMA8s2 && EMA8s2<EMA13s2 && EMA13s2<EMA50s2 && EMA50s2<EMA100s2
         && (DIgab<=0||min1>plu1+DIgab) //(!(EMA5s3<EMA8s3 && EMA8s3<EMA13s3 && EMA13s3<EMA50s3 && EMA50s3<EMA100s3)&&!(EMA5s4<EMA8s4 && EMA8s4<EMA13s4 && EMA13s4<EMA50s4 && EMA50s4<EMA100s4)&&!(EMA5s5<EMA8s5 && EMA8s5<EMA13s5 && EMA13s5<EMA50s5 && EMA50s5<EMA100s5))
        )
         trade=2;
      else
         trade = 0;
//=====================================================================*/
   if(total==0)
     {
      GlobalVariableSet("AccOpenLot",0);
      ObjectDelete("Risk");
      ObjectDelete("Risk2");
     }
//mm=====================================================================*/
   if(GlobalVariableGet("HiAccBL")>0)
      HiAccbalance = GlobalVariableGet("HiAccBL");
   if(AccountBalance()+AccountCredit()>HiAccbalance && HiAccbalance>0)
     {
      HiAccbalance = AccountBalance()
                     +AccountCredit();
      GlobalVariableSet("HiAccBL",AccountBalance()+AccountCredit());
     }
   if(BaseProfit>0 && GlobalVariableGet("HiAccBL")>AccountBalance()+AccountCredit())
      GlobalVariableSet("BaseProfit",1);
   else
      GlobalVariableSet("BaseProfit",BaseProfit);
   if(!FixBaseBalance)
     {
      if(AccountLeverage()>1000)
         BaseBalance1 = MathMax(100,BaseBalance)*1;
      if(AccountLeverage()>500 && AccountLeverage()<=1000)
         BaseBalance1 = MathMax(100,BaseBalance)*2;
      if(AccountLeverage()<=500)
         BaseBalance1 = MathMax(100,BaseBalance)*4;
     }
   else
      BaseBalance1 = BaseBalance;

   if(RiskOrders>0 && total>=RiskOrders && GlobalVariableGet("MarginLevel")<=RiskMarginLevel)
     {
      BaseBalance1 = AccountBalance();
      Risk_Alert();
     }

   if(HiOrderLots>=MarketInfo(Symbol(),MODE_MAXLOT) && AccountBalance()<=LimitBalance)
      LimitBalance=AccountBalance()/1.7;

   mm = MathMax(1,MathFloor(MathMin(LimitBalance,(AccountBalance()+AccountCredit()))/BaseBalance1));
   if(BoostOrders>0 && BoostX>0 && total<BoostOrders)
      Lots = NormalizeDouble(MathMin(MathMax(LotStep1*mm*BoostX,minLot1),MaxBaseLot),log10(1/MathMax(LotStep1,MarketInfo(Symbol(),MODE_LOTSTEP))));
   else
      Lots = NormalizeDouble(MathMin(MathMax(LotStep1*mm,minLot1),MaxBaseLot),2);
   Lots2=Lots;
   if(AccountBalance()+AccountCredit()<GlobalVariableGet("HiAccBL") && AccountEquity()<GlobalVariableGet("HiAccBL"))
     {
      Lots2 = MathMax(LotStep1,NormalizeDouble(MathMax(LotStep1,MarketInfo(Symbol(),MODE_LOTSTEP))*(HiAccbalance-(AccountBalance()+AccountCredit()))*GlobalVariableGet("MartingaleMultiplier"),2));
     }
   Lots3 = MathMin(MathMax(Lots,Lots2-GlobalVariableGet("AccOpenLot")),MaxLot);
   if(GlobalVariableGet("ErrNoMoney")==1 && Lots3>Lots)
      Lots3=Lots;
   if(Lots2>HiLots2)
      HiLots2 = Lots2;
//-------------------------------------------------------------------
   if(GlobalVariableGet("AccOpenLot")>=Lots2)
      Lots3=Lots;
//-------------------------------------------------------------------
   double BuyOrderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,B)),MaxLot),2));
   double SelOrderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,S)),MaxLot),2));
//if(BuyOrderlot>HiOrderLots)  HiOrderLots=BuyOrderlot;
//if(SelOrderlot>HiOrderLots)  HiOrderLots=SelOrderlot;
///=====================================================================
   double dw=0;
   if(OrderSelect(OrdersHistoryTotal()-1,SELECT_BY_POS,MODE_HISTORY)==true)
      int LastClosedMagic = OrderMagicNumber();
   for(int l1=1; l1<=OrdersHistoryTotal(); l1++)
     {
      if(OrderSelect(OrdersHistoryTotal()-l1,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderMagicNumber()==Magic && OrderCloseTime()>LastMagicOrderCloseTime)
            LastMagicOrderCloseTime = OrderCloseTime();
         if(OrderMagicNumber()==0 && LastClosedMagic==0 && OrderCloseTime()>=LastMagicOrderCloseTime)
            dw = NormalizeDouble(dw+OrderProfit(),2);
        }
     }

   if(LastClosedMagic==Magic)
      GlobalVariableSet("LastHiProfitBL",GlobalVariableGet("HiProfitBL"));
   if(LastClosedMagic==0 && LastMagicOrderCloseTime>0)
      GlobalVariableSet("HiProfitBL",GlobalVariableGet("LastHiProfitBL")+dw);


   int mmm = MathMax(1,MathFloor(GlobalVariableGet("HiProfitBL")/BaseBalance1));
   double CloseMagicProfit;
   if(GlobalVariableGet("HiProfitBL")<BaseBalance1||BaseProfit==0)
      CloseMagicProfit = GlobalVariableGet("HiProfitBL")*CloseMagicProfitPC/100;
   else
      CloseMagicProfit = NormalizeDouble(BaseProfit*mmm,2);

   if(((CloseMagicProfit>0 && AccountEquity() > GlobalVariableGet("HiProfitBL")+CloseMagicProfit && (LastClosedMagic==Magic||LastClosedMagic==Magic*2||AccountProfit()>CloseMagicProfit) && !(DayOfWeek()==1&&Hour()<1)) ||
       (SaftMarginLevel>0 && SaftEquity>0 && GlobalVariableGet("MarginLevel")<GlobalVariableGet("SaftMarginLevel") && AccountEquity()>GlobalVariableGet("SaftEquity") && !(DayOfWeek()==1&&Hour()<1)) || (minMarginLevel>0 && GlobalVariableGet("MarginLevel")<GlobalVariableGet("minMarginLevel")&& !(DayOfWeek()==1&&Hour()<1)) ||
       (GlobalVariableGet("EquityTrail")>0 && GlobalVariableGet("HiEquity")-GlobalVariableGet("EquityTrail")*mmm>GlobalVariableGet("HiAccBL")+TrailMinProfit*mmm && AccountEquity()<GlobalVariableGet("HiEquity")-GlobalVariableGet("EquityTrail")*mmm && AccountEquity()>GlobalVariableGet("HiAccBL")+TrailMinProfit*mmm && (LastClosedMagic==Magic||AccountProfit()>CloseMagicProfit) && !(DayOfWeek()==1&&Hour()<1)) ||
       (ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true && ObjectGetInteger(0,"CloseAll",OBJPROP_STATE)==true) ||
       (CloseMagicProfit>0 && AccountProfit()>CloseMagicProfit && AccountEquity()>=GlobalVariableGet("HiAccBL")+CloseMagicProfit)))
      GlobalVariableSet("TakeMagicProfit",1);

   if(GlobalVariableGet("TakeMagicProfit")==1)
     {
      Print("Close All Orders By CloseMagicProfitPC @ ",DoubleToStr(AccountEquity(),2));
      CloseSym();
      if(total>0)
         CloseSym();
      ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
     }

//----------------------------------------------------------------------------------------------------------------------------------
   if(total>HiTotal)
      HiTotal=total;
   double DDpercent,HiProp;
   if(AccountBalance()>0)
     {
      DDpercent = NormalizeDouble(AccountProfit()/MathMax(GlobalVariableGet("HiestEquity"),HiAccbalance)*100,2);
      HiProp = MathMax(AccountBalance(),AccountEquity());
     }
   if(Hour()<=SartQuotesHour && Minute()<=5)
     {
      if(HiProp>TodayHiProp)
         TodayHiProp = HiProp;
      TodayProfit  = 0;
      TodayMaxDD   = 0;
     }
   if(TodayHiProp>0)
      TodayProfit = (AccountEquity()-TodayHiProp)/TodayHiProp*100;
   if(TodayProfit<TodayMaxDD)
      TodayMaxDD = TodayProfit;
   if(TodayMaxDD<DaysMaxDD)
      DaysMaxDD = TodayMaxDD;
//-------------------------------------------------------------------------------------------------------------------------------------------------
   double AcProfitPercent;
   if(AccountBalance()>0)
      AcProfitPercent = AccountProfit()/MathMax(GlobalVariableGet("HiestEquity"),HiAccbalance)*100;
   if(AcProfitPercent<LowAcProfitPercent)
      LowAcProfitPercent = AcProfitPercent;
   if(MaxDrawDownPercent>0 && DDpercent<-MaxDrawDownPercent)
     {
      Print("Close All Orders By MaxDrawDownPercent @ ",DoubleToStr(AccountEquity(),2));
      CloseSym();
      if(OrdersTotal()>0)
         CloseSym();
      ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
     }
   if(MaxDrawDownPercent>0 && MaxOrder>0 && total>=MaxOrder)
     {
      Comment(onscreen);
      Print("Close All Orders By MaxOrder @ ",DoubleToStr(AccountEquity(),2));
      CloseSym();
      if(OrdersTotal()>0)
         CloseSym();
      ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
     }

   int TSP=0;
   int OrderRange = (HiOrderOpenPrice-LoOrderOpenPrice)/Point;
   if(OrderRange>HiOrderRange)
      HiOrderRange = OrderRange;
   if(total==0)
     {
      HiOrderOpenPrice = 0;
      LoOrderOpenPrice = 9999999;
      OrderRange = 0;
     }

   double TakeTypeProfit1 = TakeTypeProfit;

   if(BoostOrders>0 && BoostX>0 && ((B<=BoostOrders+1&&S==0)||(S<=BoostOrders+1&&B==0)))
      TakeSymProfit1 = TakeSymProfit*mm*BoostX;
   else
      if(AutoIncreaseTakeSymProfit)
         TakeSymProfit1 = TakeSymProfit*mm*MathMax(1,MathMax(B,S));
      else
         TakeSymProfit1 = TakeSymProfit*mm;

   double ProfitPercent;
   if(B+S==0)
      StartEquity = AccountEquity();
   if(StartEquity>0)
      ProfitPercent = (AccountEquity()-StartEquity)/StartEquity*100;
   if(TargetProfitPercent>0 && ProfitPercent>TargetProfitPercent)
      TSP = 1;


   if(TakeSymProfit>0 && BuyProfit+BuyProfit1+SelProfit+SelProfit1>TakeSymProfit1)
      //|| (MaxOrder>0&&total>MaxOrder))
     {
      TSP=1;
     }
   if(TSP==1)
     {
      Print("Close All ",Symbol()," By TakeSymProfit @ ",DoubleToStr(BuyProfit+BuyProfit1+SelProfit+SelProfit1,2));
      CloseSym();
      //while(B+S+B1+S1>0)
      //  {CloseSym(); break;}
      if(B+S+B1+S1==0)
        {B=0; S=0; B1=0; S1=0;}
     }
   if(TakeTypeProfit>0 && B>0 && (Trend != "Up" && BuyProfit+BuyProfit1>TakeTypeProfit*mm*B))//EMA8s1<BigTrendEMA0 && ATR0<ATRlevel && (Trend != "Up" && BuyProfit+BuyProfit1>TakeTypeProfit*mm*B))
     {
      TSP=2;
     }
   if(TSP==2)
     {
      Print("Close Buy ",Symbol()," By TakeBuyProfit @ ",DoubleToStr(BuyProfit+BuyProfit1,2));
      CloseBuy();
      while(B+B1>0)
        {CloseBuy(); break;}
      if(B+B1==0)
        {B=0; B1=0;}
     }
   if(TakeTypeProfit>0 && S>0 && (Trend != "Down" && SelProfit+SelProfit1>TakeTypeProfit*mm*S))//EMA8s1>BigTrendEMA0 && ATR0<ATRlevel && (Trend != "Down" && SelProfit+SelProfit1>TakeTypeProfit*mm*S))
     {
      TSP=3;
     }
   if(TSP==3)
     {
      Print("Close Sell ",Symbol()," By TakeSelProfit @ ",DoubleToStr(SelProfit+SelProfit1,2));
      CloseSel();
      while(S+S1>0)
        {CloseSel(); break;}
      if(S+S1==0)
        {S=0; S1=0;}
     }
   if(LimitLoss>0 && BuyProfit+BuyProfit1+SelProfit+SelProfit1 <= -LimitLoss*mm)
     {
      Print("Close All ",Symbol()," By LimitLoss @ ",DoubleToStr(BuyProfit+BuyProfit1+SelProfit+SelProfit1,2));
      CloseSym();
      while(B+S+B1+S1>0)
        {CloseSym(); break;}
      if(B+S+B1+S1==0)
        {B=0; S=0; B1=0; S1=0;}
     }

   int win;
   if(GlobalVariableGet("TakeMagicProfit")==1 && OrdersTotal()==0)
     {
      win = 1;
      GlobalVariableDel("TakeMagicProfit");
      total=0;
      GlobalVariableSet("HiProfitBL",AccountEquity());
      dw=0;
      GlobalVariableSet("HiEquity",0);
      HiAccbalance = AccountBalance()+AccountCredit();
      GlobalVariableSet("HiAccBL",AccountBalance()+AccountCredit());
      GlobalVariableSet("HiProfitBL",AccountEquity());
     }
   if(TSP==1 || TSP==2 || TSP==3)
     {
      win = 1;
      dw=0;
      HiAccbalance = AccountBalance()
                     +AccountCredit();
      GlobalVariableSet("HiAccBL",AccountBalance()+AccountCredit());
     }
   GlobalVariableSet("won",GlobalVariableGet("won")+win);
   if(OrdersTotal()==0 || total==0 || B==0 || S==0)
     {
      GlobalVariableDel("TakeMagicProfit");
      win = 0;
      TSP = 0;
     }
   ObjectSetInteger(0,"CloseAll",OBJPROP_STATE,false);
//-------------------------------------------------------------------
   if(total==0)
     {
      GlobalVariableDel("AccOpenLot");
      ObjectDelete("Risk");
      ObjectDelete("Risk2");
     }
//=====================================================================*/
   int TradeRank;
   if(GlobalVariableGet("ChartsTotal")>1 && k<GlobalVariableGet("ChartsTotal")*4-1)
     {
      k++;
      TradeRank=k;
     }
   if(TradeRank==0)
      k=0;
   GlobalVariableSet("TradeRank",TradeRank);
///=====================================================================
   if(AccountEquity()>GlobalVariableGet("HiEquity"))
      GlobalVariableSet("HiEquity",AccountEquity());
   if(AccountEquity()>GlobalVariableGet("HiestEquity"))
      GlobalVariableSet("HiestEquity",AccountEquity());
///=====================================================================
   bool result;
   double SymProfit;
   for(int iii=OrdersTotal(); iii>=0; iii--)
     {
      if(OrderSelect(iii,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()== Magic && OrderSymbol()==Symbol())
        {
         SymProfit = SymProfit+OrderProfit()+OrderCommission()+OrderSwap();

         /*if(TakeTypeProfit1>0 && BuyProfit+BuyProfit1<SelProfit+SelProfit1 && BuyProfit+BuyProfit1>TakeTypeProfit1*mm)
           {
            TSP=2;
           }
         if(TakeTypeProfit1>0 && SelProfit+SelProfit1<BuyProfit+BuyProfit1 && SelProfit+SelProfit1>TakeTypeProfit1*mm)
           {
            TSP=3;
           }
         if(SymStopLoss>0 && trade==1 && adx1>20 && OrderType()==OP_SELL)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result==TRUE)
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by trade==1");
           }
         if(SymStopLoss>0 && trade==2 && adx1>20 && OrderType()==OP_BUY)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result==TRUE)
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by trade==2");
           }
         if(SymStopLoss>0 && trade==3 && adx1>20 && OrderType()==OP_SELL)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result==TRUE)
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by trade==3");
           }
         if(SymStopLoss>0 && trade==4 && adx1>20 && OrderType()==OP_BUY)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result==TRUE)
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by trade==4");
           }*/
         if(OrderProfit()>HiOrderProfit)
            HiOrderProfit = OrderProfit();
         if(OrderProfit()==0)
            HiOrderProfit = 0;

         /* if(OrderType()==OP_SELL && OrderProfit()>1*OrderLots()/LotStep1 && OrderProfit()<(HiOrderProfit-5)*OrderLots()/LotStep1)
            {
             result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
             if(result==TRUE)
                BreakEven_Sell = TRUE;
             Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by BreakEven_Sell");
            }
          if(OrderType()==OP_BUY && OrderProfit()>1*OrderLots()/LotStep1 && OrderProfit()<(HiOrderProfit-5)*OrderLots()/LotStep1)
            {
             result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
             if(result==TRUE)
                BreakEven_Buy = TRUE;
             Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by BreakEven_Buy");
            }*/

         if(OrderType()==OP_SELL && (HedgeOrders==0||B>HedgeOrders) && ProfitTrail>0 && OrderProfit()>TrailMinProfit*OrderLots()/LotStep1 && (ProfitTrail==1||OrderProfit()<(HiOrderProfit-ProfitTrail)*OrderLots()/LotStep1) && spread1<=LimitSpread)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result==TRUE)
               StopLossSel = TRUE;
            Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by TrailingProfit");
           }
         if(OrderType()==OP_BUY && (HedgeOrders==0||S>HedgeOrders) && ProfitTrail>0 && OrderProfit()>TrailMinProfit*OrderLots()/LotStep1 && (ProfitTrail==1||OrderProfit()<(HiOrderProfit-ProfitTrail)*OrderLots()/LotStep1) && spread1<=LimitSpread)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result==TRUE)
               StopLossBuy = TRUE;
            Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by TrailingProfit");
           }
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && StopLoss>0 && (trade == 1 || OrderProfit()<=-StopLoss*OrderLots()/LotStep1))
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result=TRUE)
              {
               StopLossSel = TRUE;
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by StopLossSel");
              }
           }
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && StopLoss>0 && (trade == 2 || OrderProfit()<=-StopLoss*OrderLots()/LotStep1))
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result=TRUE)
              {
               StopLossBuy = TRUE;
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by StopLossBuy");
              }
           }
        }
      // else Print( "Error when order select ", GetLastError());
     }
///Open Magic=====================================================================
   double orderlot;
//snowball Buy------------------------------------------------------------------+
   if(!(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true && total==0) && (ChartRank-1)*4==GlobalVariableGet("TradeRank") && //!StopLossBuy &&
      GlobalVariableGet("TakeMagicProfit")==0 && !(DayOfWeek()==1&&Hour()<1) && (LimitSpread<=0||spread1<=LimitSpread) &&
      ((trade==1 && B==0)||
       (SnowBall && trade==1 && LastBuyOP>0 && SnOrderStep>0 && LastBuyOrderProfit>((LastBuyOL/LotStep1)*SnOrderStep*(B+SnOrderStep)*0.05))
      )
      && (MaxOrder<=0 || total<MaxOrder) && LastBuyOT<Time[0]
      && StringFind(CanceledSymbol,Symbol())<0 &&  SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_DISABLED)
     {
      orderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,B)),MaxLot),2));
      if(orderlot>HiOrderLots)
         HiOrderLots=orderlot;
      int ticket=OrderSend(Symbol(),OP_BUY,orderlot,ask1,5,0,0,"snowballBUY",Magic,0,Green);
      if(GlobalVariableGet("TakeMagicProfit")!=1)
         Sleep(1*60*1000);
      if(ticket>0)
        {
         BreakEven_Sell = FALSE;
         StopLossSel=FALSE;
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            Print("snowballBUY ",OrderLots(),OrderSymbol(),"#",OrderTicket(),"@",OrderOpenPrice());
         GlobalVariableDel("ErrNoMoney");
        }
      else
        {
         Print("snowballBUY",Symbol()," Error = ",ErrorDescription(GetLastError()));
         Sleep(1000*60*60);
        }
      return;
     }
//martingale Buy------------------------------------------------------------------+
   if(!(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true && total==0) && (ChartRank-1)*4==GlobalVariableGet("TradeRank") && //!StopLossBuy &&
      GlobalVariableGet("TakeMagicProfit")==0 && !(DayOfWeek()==1&&Hour()<1) && (LimitSpread<=0||spread1<=LimitSpread) &&
      ((trade==1 && B==0)||
       (Martingale && trade==1 && LastBuyOP>0 && MaOrderStep>0 && LastBuyOrderProfit<-((LastBuyOL/LotStep1)*MaOrderStep*(B+SnOrderStep)*0.05))
      )
      && (MaxOrder<=0 || total<MaxOrder)&& LastBuyOT<Time[0]
      && StringFind(CanceledSymbol,Symbol())<0 &&  SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_DISABLED)
     {
      orderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,B)),MaxLot),2));
      if(orderlot>HiOrderLots)
         HiOrderLots=orderlot;
      ticket=OrderSend(Symbol(),OP_BUY,orderlot,ask1,5,0,0,"MartingaleBuy",Magic,0,Green);
      if(GlobalVariableGet("TakeMagicProfit")!=1)
         Sleep(1*60*1000);
      if(ticket>0)
        {
         BreakEven_Sell = FALSE;
         StopLossSel=FALSE;
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            Print("MartingaleBuy ",OrderLots(),OrderSymbol(),"#",OrderTicket(),"@",OrderOpenPrice());
         GlobalVariableDel("ErrNoMoney");
        }
      else
        {
         Print("Martingale Buy ",Symbol()," Error = ",ErrorDescription(GetLastError()));
         Sleep(1000*60*60);
        }
      return;
     }

//snowball Sell------------------------------------------------------------------+
   if(!(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true && total==0) && (ChartRank-1)*4==GlobalVariableGet("TradeRank") && //!StopLossSel &&
      GlobalVariableGet("TakeMagicProfit")==0 && !(DayOfWeek()==1&&Hour()<1) && (LimitSpread<=0||spread1<=LimitSpread) &&
      ((trade==2 && S==0)||
       (SnowBall && trade==2 && LastSellOP>0 && SnOrderStep>0 && LastSelOrderProfit>((LastSelOL/LotStep1)*SnOrderStep*(S+SnOrderStep)*0.05))
      )
      && (MaxOrder<=0 || total<MaxOrder)
      && StringFind(CanceledSymbol,Symbol())<0 &&  SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_DISABLED)
     {
      orderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,S)),MaxLot),2));
      if(orderlot>HiOrderLots)
         HiOrderLots=orderlot;
      ticket=OrderSend(Symbol(),OP_SELL,orderlot,bid1,5,0,0,"snowballSell",Magic,0,Red);
      if(GlobalVariableGet("TakeMagicProfit")!=1)
         Sleep(1*60*1000);
      if(ticket>0)
        {
         BreakEven_Buy = FALSE;
         StopLossBuy=FALSE;
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            Print("snowballSell ",OrderLots(),OrderSymbol(),"#",OrderTicket(),"@",OrderOpenPrice());
         GlobalVariableDel("ErrNoMoney");
        }
      else
        {
         Print("snowballSell ",Symbol()," Error = ",ErrorDescription(GetLastError()));
         Sleep(1000*60*60);
        }
      return;
     }
//Martingale Sell------------------------------------------------------------------+
   if(!(ObjectGetInteger(0,"Pause",OBJPROP_STATE)==true && total==0) && (ChartRank-1)*4==GlobalVariableGet("TradeRank") && //!StopLossSel &&
      GlobalVariableGet("TakeMagicProfit")==0 && !(DayOfWeek()==1&&Hour()<1) && (LimitSpread<=0||spread1<=LimitSpread) &&
      ((trade==2 && S==0)||
       (Martingale && trade==2 && LastSellOP>0 && SnOrderStep>0 && LastSelOrderProfit<-((LastSelOL/LotStep1)*MaOrderStep*(S+SnOrderStep)*0.05))
      )
      && (MaxOrder<=0 || total<MaxOrder) && LastSelOT<Time[0]
      && StringFind(CanceledSymbol,Symbol())<0 &&  SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_DISABLED)
     {
      orderlot = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),NormalizeDouble(MathMin(MathMax(Lots3,Lots3*pow(LotX,S)),MaxLot),2));
      if(orderlot>HiOrderLots)
         HiOrderLots=orderlot;
      ticket=OrderSend(Symbol(),OP_SELL,orderlot,bid1,5,0,0,"MartingaleSELL",Magic,0,Red);
      if(GlobalVariableGet("TakeMagicProfit")!=1)
         Sleep(1*60*1000);
      if(ticket>0)
        {
         BreakEven_Buy = FALSE;
         StopLossBuy=FALSE;
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
            Print("MartingaleSELL ",OrderLots(),OrderSymbol(),"#",OrderTicket(),"@",OrderOpenPrice());
         GlobalVariableDel("ErrNoMoney");
        }
      else
        {
         Print("MartingaleSELL ",Symbol()," Error = ",ErrorDescription(GetLastError()));
         Sleep(1000*60*60);
        }
      return;
     }
//-------------------------------------------------------------------------------------------------------------------------------------------------
   onscreen = StringConcatenate("SnOrderSep="+SnOrderStep+"  MaOrderSep="+MaOrderStep+"  BaseProfit=",GlobalVariableGet("BaseProfit"),"  BaseBalance1=",BaseBalance1,
                                "  BaseLots=",Lots,"  BuyLots="+BuyOrderlot+"  SelLots="+SelOrderlot,"  MaxBaseLot=",MaxBaseLot,"  maxOrder=",MaxOrder,
                                "  LowMarginLevel="+DoubleToStr(GlobalVariableGet("LowMarginLevel"),2),"  HiSpread="+HiSpread+"  TSP="+TSP+"  B="+B+"  S="+S+
                                "  BuyLots="+BuyLots+"  SelLots="+SelLots+"  StartEquity="+DoubleToStr(StartEquity,2)+"  ProfitPercent="+DoubleToStr(ProfitPercent,2)+"%"+

                                "\nCurrentTime=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"  AccBalance=",DoubleToStr(AccountBalance()+AccountCredit(),2),
                                "  AccEquity=",DoubleToStr(AccountEquity(),2)+"  total=",total,"  HiTotal="+HiTotal+"  AccOpenLot="+DoubleToStr(GlobalVariableGet("AccOpenLot"),2),
                                "  Magic="+Magic,"  MinLot=",DoubleToStr(MarketInfo(Symbol(),MODE_MINLOT),2),"  LotStep=",DoubleToStr(MarketInfo(Symbol(),MODE_LOTSTEP),2),
                                "  MaxLot=",DoubleToStr(MarketInfo(Symbol(),MODE_MAXLOT),2),"  LimitOrders="+AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),
                                "  HiAccBalance="+DoubleToStr(GlobalVariableGet("HiAccBL"),2)+"  HiLot2="+DoubleToStr(HiLots2,2)+"  AccountProfit = ",DoubleToStr(AccountCredit()+AccountBalance()-(Deposit+AccountCredit()),2),
                                "(",DoubleToStr(((AccountCredit()+AccountBalance()-(Deposit+AccountCredit()))/(Deposit+AccountCredit())*100),2),"%)"+

                                "\nSymbol=",Symbol(),"  Pause=",ObjectGetInteger(0,"Pause",OBJPROP_STATE),"  CloseAll=",ObjectGetInteger(0,"CloseAll",OBJPROP_STATE),
                                "  Deposit+Wihdrawn="+DoubleToStr(dw,2)+"  HiestEquity=",DoubleToStr(GlobalVariableGet("HiestEquity"),2),
                                "  MarginLevel=",DoubleToStr(GlobalVariableGet("MarginLevel"),2)+"  TradeRank="+GlobalVariableGet("TradeRank")+"  mm="+mm+
                                "  DD%="+DoubleToStr(DDpercent,2)+"  MaxDD%="+DoubleToStr(LowAcProfitPercent,2)+"/-"+MaxDrawDownPercent+
                                "  TakeSymProfit1="+TakeSymProfit1+"  ADXLevel="+adxLevel+"  adx1="+DoubleToStr(adx1,2)+"  SideWayBar11="+SideWayBar1+"  SideWaySlope1="+SideWaySlope1+"  EMAslope="+MAslope1+

                                "\nHiProfitBalance="+DoubleToStr(GlobalVariableGet("HiProfitBL"),2)+"  TargetEquity="+DoubleToStr(GlobalVariableGet("HiProfitBL")+CloseMagicProfit,2)+
                                "  Equity="+DoubleToStr(AccountEquity(),2)+"  HiEquity="+DoubleToStr(GlobalVariableGet("HiEquity"),2)+"  won="+GlobalVariableGet("won")+
                                "  LastHiProfitBL="+DoubleToStr(GlobalVariableGet("LastHiProfitBL"),2)+"  HiOrderProfit="+DoubleToStr(HiOrderProfit,2)+
                                "  BuyProfit="+DoubleToStr(BuyProfit+BuyProfit1,2)+"  SelProfit="+DoubleToStr(SelProfit+SelProfit1,2)+
                                "  SymProfit="+DoubleToStr(BuyProfit+BuyProfit1+SelProfit+SelProfit1,2)+"  trade="+trade+"  Trend="+Trend+
                                "  SnowBall="+SnowBall+"  Martingale="+Martingale+"  HedgeOrders="+HedgeOrders+" StopLossBuy="+StopLossBuy+" StopLossSel="+StopLossSel+

                                "\nHiOrderLots="+HiOrderLots+"  LimitBalance="+DoubleToStr(LimitBalance,2)+"  Lots2="+Lots2+"  AccountStopoutLevel="+AccountStopoutLevel()+
                                "  Leverage="+AccountLeverage()+"  TodayProfit%="+DoubleToStr(TodayProfit,2)+"  TodayMaxDD%="+DoubleToStr(TodayMaxDD,2)+
                                "  DaysMaxDD%="+DoubleToStr(DaysMaxDD,2)+"  OrdersRange="+OrderRange+"  HiOrdersRange="+HiOrderRange+
                                "  ATRlevel="+ATRlevel+"  ATR="+DoubleToStr(ATR0,4)+"  SideWayBar5="+SideWayBar5+"  SideWaySlope5="+SideWaySlope5);
   /*----------------------
   onscreen = StringConcatenate("MarginLevel=",DoubleToStr(GlobalVariableGet("MarginLevel"),2),"  LowMarginLevel="+DoubleToStr(GlobalVariableGet("LowMarginLevel"),2),
           "  Deposit="+Deposit,"  AccountProfit = ",DoubleToStr(AccountCredit()+AccountBalance()-(Deposit+AccountCredit()),2),
           "(",DoubleToStr(((AccountCredit()+AccountBalance()-(Deposit+AccountCredit()))/(Deposit+AccountCredit())*100),2),"%)",
           "  HiSpread="+HiSpread+"  Buy="+B+"  Sell="+S+"  BaseLots=",Lots,"  BuyLots="+BuyLots+"  SelLots="+SelLots,
           "  BuyProfit="+DoubleToStr(BuyProfit+BuyProfit1,2)+"  SelProfit="+DoubleToStr(SelProfit+SelProfit1,2)+
           "  SymProfit="+DoubleToStr(BuyProfit+BuyProfit1+SelProfit+SelProfit1,2)+"  TakeSymProfit="+TakeSymProfit1+
           "  trade="+trade+"  SnowBall="+SnowBall+"  Martingale="+Martingale,

           "\nAccountStopoutLevel="+AccountStopoutLevel()+"  Leverage="+AccountLeverage()+"  TodayProfit%="+DoubleToStr(TodayProfit,2)+
           "  TodayMaxDrawdown%="+DoubleToStr(TodayMaxDD,2)+"  MaxDrawdown%="+DoubleToStr(DaysMaxDD,2));
   //----------------------*/
   Comment(onscreen);
//--- return value of Start Function
   return;
  }
//=========================================================================================================================================================================
void CloseAll()
  {
   bool result;

   for(int i=OrdersTotal(); i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==OP_SELL)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result=TRUE)
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by CloseAll()");
            else
              {
               Print("CloseAll() Sell ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_BUY)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result=TRUE)
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by CloseAll()");
            else
              {
               Print("CloseAll() Buy ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
           {
            result=OrderDelete(OrderTicket(),clrGold);
            if(result=TRUE)
               Print("Deleted Pending Orders ",OrderSymbol(),"#",OrderTicket()," by CloseAll()");
            else
              {
               Print("CloseAll() Deleted Pending Orders ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
        }
      // else Print( "Error when order select ", GetLastError());
     }
  }
//=========================================================================================================================================================================
void CloseSym()
  {
   bool result;
   for(int i=OrdersTotal(); i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic||OrderMagicNumber()==Magic*2))
        {
         if(OrderType()==OP_SELL)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result=TRUE)
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by CloseSym()");
            else
              {
               Print("CloseSym() Sell ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_BUY)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result=TRUE)
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by CloseSym()");
            else
              {
               Print("CloseSym() Buy ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
           {
            result=OrderDelete(OrderTicket(),clrGold);
            if(result=TRUE)
               Print("Deleted Pending Orders ",OrderSymbol(),"#",OrderTicket()," by CloseSym()");
            else
              {
               Print("CloseSym() Deleted Pending Orders ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
        }
      // else Print( "Error when order select ", GetLastError());
     }
  }
//============================================================================================================================================
void CloseBuy()
  {
   bool result;
   for(int i=OrdersTotal(); i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic||OrderMagicNumber()==Magic*2))
        {
         if(OrderType()==OP_BUY)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrMediumBlue);
            if(result=TRUE)
               Print("Closed Buy ",OrderSymbol(),"#",OrderTicket()," by CloseBuy()");
            else
              {
               Print("CloseBuy() ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_BUYSTOP)
           {
            result=OrderDelete(OrderTicket(),clrGold);
            if(result=TRUE)
               Print("Deleted Pending Orders ",OrderSymbol(),"#",OrderTicket()," by CloseBuy()");
            else
              {
               Print("CloseBuy() Deleted Pending Orders ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
        }
      // else Print( "Error when order select ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
void CloseSel()
  {
   bool result;
   for(int i=OrdersTotal(); i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==Symbol() && (OrderMagicNumber()==Magic||OrderMagicNumber()==Magic*2))
        {
         if(OrderType()==OP_SELL)
           {
            result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrRed);
            if(result=TRUE)
               Print("Closed Sell ",OrderSymbol(),"#",OrderTicket()," by CloseSel()");
            else
              {
               Print("CloseSel() ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
         if(OrderType()==OP_SELLSTOP)
           {
            result=OrderDelete(OrderTicket(),clrGold);
            if(result=TRUE)
               Print("Deleted Pending Orders ",OrderSymbol(),"#",OrderTicket()," by CloseSel()");
            else
              {
               Print("CloseSell() Deleted Pending Orders ",Symbol()," Error = ",ErrorDescription(GetLastError()));
               Sleep(1000*60*60);
              }
           }
        }
      // else Print( "Error when order select ", GetLastError());
     }
  }
//+------------------------------------------------------------------+
string Status()
  {
   string cookie=NULL,headers,resHeaders,status;
   char post[],result[];
   int res;
//--- to enable access to the server, you should add URL "https://script.google.com/macros/s/AKfycby5g2Ylun33qBL2VeUbWEE4NVQTgxSPkfXll3OiMtw14TN0d_QWRizoSgYUddAeUp3Yow/exec"
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
   string url1 = URL;
   string gs_url = StringConcatenate(url1,"?","accNumber="+AccountNumber(),"&accBalance="+NormalizeDouble(AccountBalance(),2),"&accEquity="+NormalizeDouble(AccountEquity(),2),
                                     "&accFreeMargin="+NormalizeDouble(AccountFreeMargin(),2),"&accProfit="+NormalizeDouble(AccountProfit(),2),"&accLeverage="+AccountLeverage(),
                                     "&accStopoutLevel="+AccountStopoutLevel(),"&accServer="+AccountServer(),"&accCompany="+AccountCompany(),
                                     "&accName="+AccountName(),"&expertName="+expertName);
   int replaced=StringReplace(gs_url," ","%20");

//--- Loading a html page from Google Finance
   int timeout=15000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
   res=WebRequest("GET",gs_url,headers,timeout,post,result,resHeaders);
//--- Reset the last error code
   ResetLastError();
//--- Checking errors
   if(res==-1)
     {
      //Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      // MessageBox("Add the address '"+gs_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully
      //PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file
      int filehandle=FileOpen("AcStatus"+AccountNumber()+".txt",FILE_WRITE|FILE_BIN);
      //--- Checking errors
      if(filehandle!=INVALID_HANDLE)
        {
         //--- Save the contents of the result[] array to a file
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- Close the file
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error = ",ErrorDescription(GetLastError()));

      res = 0;  //reset the result
     }
   res = 0;  //reset the result
   int ReadFile_handle = FileOpen("AcStatus"+AccountNumber()+".txt",FILE_READ);
   status = FileReadString(ReadFile_handle);
   FileClose(ReadFile_handle);
//Print(status);
   return(status);
  }
//+------------------------------------------------------------------+
//---Risk Alert LABEL---
void Risk_Alert()
  {
   ObjectCreate("Risk",OBJ_LABEL,0,0,0);
   ObjectSet("Risk",OBJPROP_CORNER,3);
   ObjectSet("Risk",OBJPROP_XDISTANCE,10);
   ObjectSet("Risk",OBJPROP_YDISTANCE,130);
   ObjectSetText("Risk","Your account is in High Risk,",15,"Tahoma",clrRed);
   ObjectSetInteger(0,"Risk",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"Risk",OBJPROP_SELECTED,false);

   ObjectCreate("Risk2",OBJ_LABEL,0,0,0);
   ObjectSet("Risk2",OBJPROP_CORNER,3);
   ObjectSet("Risk2",OBJPROP_XDISTANCE,10);
   ObjectSet("Risk2",OBJPROP_YDISTANCE,100);
   ObjectSetText("Risk2","Please deposit to top up your account balance.",15,"Tahoma",clrRed);
   ObjectSetInteger(0,"Risk2",OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,"Risk2",OBJPROP_SELECTED,false);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Link MT4 to Firebase Realtime Database
//+------------------------------------------------------------------+
string StatusToFirebase()
  {
   string cookie=NULL,headers,resHeaders,status;
   char post[],result[];
   int res;
//--- to enable access to the server, you should add URL "https://script.google.com/macros/s/AKfycby5g2Ylun33qBL2VeUbWEE4NVQTgxSPkfXll3OiMtw14TN0d_QWRizoSgYUddAeUp3Yow/exec"
//--- in the list of allowed URLs (Main Menu->Tools->Options, tab "Expert Advisors"):
   string FirebaseURL = "https://iotpim-2020-6ce6d-default-rtdb.asia-southeast1.firebasedatabase.app/";
//string data = "{\"name\":\"John\", \"age\":30, \"city\":\"New York\"}";
   string data = StringConcatenate("{\"accNumber\":"+AccountNumber()+", \"accBalance\":"+NormalizeDouble(AccountBalance(),2)+", \"accEquity\":"+NormalizeDouble(AccountEquity(),2)+
                                   ", \"accFreeMargin\":"+NormalizeDouble(AccountFreeMargin(),2)+", \"accProfit\":"+NormalizeDouble(AccountProfit(),2)+", \"accLeverage\":"+AccountLeverage()+
                                   ", \"accStopoutLevel\":"+AccountStopoutLevel()+", \"accServer\":"+AccountServer()+", \"accCompany\":"+AccountCompany()+
                                   ", \"accName\":"+AccountName()+", \"expertName\":"+expertName+"}");
   int replaced=StringReplace(data," ","%20");
   ArrayResize(post,1);
   ArrayFill(post,0,1,data);

//--- Loading a html page from Google Finance
   int timeout=15000; //--- Timeout below 1000 (1 sec.) is not enough for slow Internet connection
   res=WebRequest("GET",FirebaseURL,headers,timeout,post,result,resHeaders);
//--- Reset the last error code
   ResetLastError();
//--- Checking errors
   if(res==-1)
     {
      //Print("Error in WebRequest. Error code  =",GetLastError());
      //--- Perhaps the URL is not listed, display a message about the necessity to add the address
      // MessageBox("Add the address '"+gs_url+"' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
     }
   else
     {
      //--- Load successfully
      //PrintFormat("The file has been successfully loaded, File size =%d bytes.",ArraySize(result));
      //--- Save the data to a file
      int filehandle=FileOpen("AcStatus"+AccountNumber()+".txt",FILE_WRITE|FILE_BIN);
      //--- Checking errors
      if(filehandle!=INVALID_HANDLE)
        {
         //--- Save the contents of the result[] array to a file
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- Close the file
         FileClose(filehandle);
        }
      else
         Print("Error in FileOpen. Error = ",ErrorDescription(GetLastError()));

      res = 0;  //reset the result
     }
   res = 0;  //reset the result
   int ReadFile_handle = FileOpen("AcStatus"+AccountNumber()+".txt",FILE_READ);
   status = FileReadString(ReadFile_handle);
   FileClose(ReadFile_handle);
//Print(status);
   return(status);
  }
//+------------------------------------------------------------------+
