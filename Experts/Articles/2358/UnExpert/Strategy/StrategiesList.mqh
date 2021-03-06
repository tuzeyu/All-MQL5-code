//+------------------------------------------------------------------+
//|                                               StrategiesList.mqh |
//|           Copyright 2016, Vasiliy Sokolov, St-Petersburg, Russia |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Vasiliy Sokolov."
#property link      "https://www.mql5.com/en/users/c-4"

#ifdef SHOW_BASE_SETTINGS
input string StrategiesXMLFile="Strategies.xml";       // Upload strategies from the file
input bool   LoadOnlyCurrentSymbol=false;              // Upload only for the current symbol
#endif 
#include <Arrays\ArrayObj.mqh>
#include "Strategy.mqh"
#include "StrategyParamsBase.mqh"
#include "EquityListener.mqh"
#include ".\Panel\Panel.mqh"
#include "RSquare.mqh"
#include "Panel\Events\EventChartListChanged.mqh"
//+------------------------------------------------------------------+
//| Determines the type of custom criterion calculated after         |
//| optimization.                                                    |
//+------------------------------------------------------------------+
enum ENUM_CUSTOM_TYPE
  {
   CUSTOM_NONE,                     // Custom criterion is not calculated
   CUSTOM_R2_BALANCE,               // R^2 based on the strategy balance
   CUSTOM_R2_EQUITY,                // R^2 based on the strategy equity
  };
//+------------------------------------------------------------------+
//| Container class to manage strategies of the CStrategy type       |
//+------------------------------------------------------------------+
class CStrategyList
  {
private:
   CEquityListener   m_equity_exp;
   CLog*             Log;                 // Logging
   CArrayObj         m_strategies;        // Strategies of the CStrategy type
   ENUM_CUSTOM_TYPE  m_custom_type;       // Custom optimization criterion
   ENUM_CORR_TYPE    m_corr_type;         // Type of correlation for R^2
   void              ParseStrategies(CXmlElement *xmlStrategies,bool load_curr_symbol);
   void              ParseLimits(CXmlElement *xmlLimits);
   CStrBtn           StrButton;
   void              AddEquityExpert(ENUM_TIMEFRAMES tf, string symbol);
public:
                     CStrategyList(void);
                    ~CStrategyList(void);
   void              LoadStrategiesFromXML(string xml_name,bool load_curr_symbol);
   bool              AddStrategy(CStrategy *strategy);
   int               Total();
   void              Clear();
   void              SetCustomOptimizeR2Balance(ENUM_CORR_TYPE corr_type);
   void              SetCustomOptimizeR2Equity(ENUM_CORR_TYPE corr_type);
   CStrategy        *At(int index);
   void              OnTick();
   void              OnTimer();
   void              OnBookEvent(string symbol);
   void              OnDeinit(const int reason);
   double            OnTester(void);
   void              OnChartEvent(const int id,
                                  const long &lparam,
                                  const double &dparam,
                                  const string &sparam);

  };
//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CStrategyList::CStrategyList(void) : StrButton(GetPointer(this))
  {
   Log=CLog::GetLog();
   StrButton.Show();
   m_strategies.Sort(0);
   m_corr_type = CORR_PEARSON;
   m_custom_type = CUSTOM_R2_EQUITY;
  }

//+------------------------------------------------------------------+
//| Note: this is the only place where CLog is deleted. In other     |
//| places no need to delete it.                                     |
//+------------------------------------------------------------------+
CStrategyList::~CStrategyList(void)
  {
   CLog::DeleteLog();
  }
//+------------------------------------------------------------------+
//| Clear the list of strategies                                     |
//+------------------------------------------------------------------+  
CStrategyList::Clear(void)
  {
   m_strategies.Clear();
  }
//+------------------------------------------------------------------+
//| Sets R^2 as the optimization criterion. The coeffi cient is      |
//| calculated for the trades made.                                  |
//+------------------------------------------------------------------+  
void CStrategyList::SetCustomOptimizeR2Balance(ENUM_CORR_TYPE corr_type)
{
   m_custom_type = CUSTOM_R2_BALANCE;
   m_corr_type = corr_type;
}
//+------------------------------------------------------------------+
//| Sets R^2 as the optimization criterion. The coefficient is       |
//| calculated based on the recorded equity.                         |
//+------------------------------------------------------------------+  
void CStrategyList::SetCustomOptimizeR2Equity(ENUM_CORR_TYPE corr_type)
{
   m_custom_type = CUSTOM_R2_EQUITY;
   m_corr_type = corr_type;
}
//+------------------------------------------------------------------+
//| Sends the OnTick event to all listed strategies                  |
//+------------------------------------------------------------------+
void CStrategyList::OnTick(void)
  {
   for(int i=0; i<m_strategies.Total(); i++)
     {
      CStrategy *strategy=m_strategies.At(i);
      strategy.OnTick();
     }
  }
//+------------------------------------------------------------------+
//| Sends the OnTimer event to all listed strategies                 |
//+------------------------------------------------------------------+
void CStrategyList::OnTimer(void)
  {
   for(int i=0; i<m_strategies.Total(); i++)
     {
      CStrategy *strategy=m_strategies.At(i);
      strategy.OnTimer();
     }
  }
//+------------------------------------------------------------------+
//| Sends OnBookEvent to all listed strategies                       |
//+------------------------------------------------------------------+
void CStrategyList::OnBookEvent(string symbol)
  {
   for(int i=0; i<m_strategies.Total(); i++)
     {
      CStrategy *strategy=m_strategies.At(i);
      strategy.OnBookEvent(symbol);
     }
  }
//+------------------------------------------------------------------+
//| Sends the OnTimer event to all listed strategies                 |
//+------------------------------------------------------------------+
/*void CStrategyList::OnDeinit(const int reason)
{
   for(int i = 0; i < m_strategies.Total(); i++)
   {
      CStrategy* strategy = m_strategies.At(i);
      strategy.OnDeinit(reason);
   }
}*/
//+------------------------------------------------------------------+
//| Returns the total number of strategies                           |
//+------------------------------------------------------------------+
int CStrategyList::Total(void)
  {
   return m_strategies.Total();
  }
//+------------------------------------------------------------------+
//| Returns a strategy with the 'index' index                        |
//+------------------------------------------------------------------+
CStrategy *CStrategyList::At(int index)
  {
   return m_strategies.At(index);
  }
//+------------------------------------------------------------------+
//| Adds a strategy to the list of strategies. The added strategy    |
//| must contain the 'magic' number, working symbol and name. i.e.   |
//| set appropriate values through the methods ExpertMagic,          |
//| ExpertSymbol & ExpertName.                                       | 
//+------------------------------------------------------------------+
bool CStrategyList::AddStrategy(CStrategy *strategy)
  {
   bool res=true;
   if(strategy.ExpertMagic()==0)
     {
      string text="The strategy should have a magic number. Adding strategy "+strategy.ExpertName()+" is impossible";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   if(strategy.ExpertName()==NULL || strategy.ExpertName()=="")
     {
      string text="The strategy should have an expert name. Adding strategy with magic "+(string)strategy.ExpertMagic()+" is impossible";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   if(strategy.ExpertSymbol()==NULL || strategy.ExpertSymbol()=="")
     {
      string text="The strategy should have a work symbol. Adding strategy "+strategy.ExpertName()+" is impossible";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   if(strategy.Timeframe()==PERIOD_CURRENT)
     {
      string text="The strategy should have a work timeframe. Adding strategy "+strategy.ExpertName()+" is impossible";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   int index = m_strategies.Search(strategy);
   if(index != -1)
     {
      string text="Strategy with Magic "+(string)strategy.ExpertMagic()+
                  " has already been added to the list of strategies. Change the Magic to be added to the strategy";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   if(!strategy.OnInit())
     {
      string text="Failed OnInit. '"+strategy.ExpertName()+"' strategy will not be added to the list";
      CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
      Log.AddMessage(msg);
      res=false;
     }
   if(res == false)return res;
   //-- Add equity listener expert
   if(m_strategies.Total() == 0)
      AddEquityExpert(strategy.Timeframe(), strategy.ExpertSymbol());
   res=m_strategies.InsertSort(strategy);
   if(res)
     {
      StrButton.AddStrategyName(strategy.ExpertNameFull());
      string text="Strategy "+strategy.ExpertNameFull()+" successfully loaded";
      CMessage *msg=new CMessage(MESSAGE_INFO,__FUNCTION__,text);
      Log.AddMessage(msg);
     }
   return res;
  }
  
void CStrategyList::AddEquityExpert(ENUM_TIMEFRAMES tf, string symbol)
{
   if(tf > PERIOD_H1)
      m_equity_exp.Timeframe(tf);
   else
      m_equity_exp.Timeframe(PERIOD_H1);
   m_equity_exp.ExpertSymbol(symbol);
   m_equity_exp.ExpertMagic(1029384);
   m_equity_exp.ExpertName("Equity Listener Expert");
   m_strategies.InsertSort(&m_equity_exp);
}
//+------------------------------------------------------------------+
//| Adds monitoring of equity                                        |
//+------------------------------------------------------------------+
double CStrategyList::OnTester(void)
{
   switch(m_custom_type)
   {
      case CUSTOM_NONE:
         return 0.0;
      case CUSTOM_R2_BALANCE:
         return CustomR2Balance(m_corr_type);
      case CUSTOM_R2_EQUITY:
      {
         double equity[];
         m_equity_exp.GetEquityArray(equity);
         int total = ArrayResize(equity, ArraySize(equity)+1);
         equity[total-1] = AccountInfoDouble(ACCOUNT_EQUITY);
         return CustomR2Equity(equity, m_corr_type);
      }
   }
   return 0.0;
}
//+------------------------------------------------------------------+
//| Loads strategies from the passed XML file "xml_name"             |
//| If the load_curr_symbol flag is set to true, it will only load   |
//| the strategies in which symbol corresponds to the current        |
//| symbol CurrentSymbol()                                           |
//+------------------------------------------------------------------+
void CStrategyList::LoadStrategiesFromXML(string xml_name,bool load_curr_symbol)
  {
   CXmlDocument doc;
   string err;
   bool res=doc.CreateFromFile(xml_name,err);
   if(!res)
      printf(err);
   CXmlElement *global=GetPointer(doc.FDocumentElement);
   for(int i=0; i<global.GetChildCount(); i++)
     {
      CXmlElement* child = global.GetChild(i);
      if(child.GetName() == "Strategies")
         ParseStrategies(child,load_curr_symbol);
     }
  }
//+------------------------------------------------------------------+
//| Parses XML strategies                                            |
//+------------------------------------------------------------------+
void CStrategyList::ParseStrategies(CXmlElement *xmlStrategies,bool load_curr_symbol)
  {
   CParamsBase *params=NULL;
   for(int i=0; i<xmlStrategies.GetChildCount(); i++)
     {
      CXmlElement *xStrategy=xmlStrategies.GetChild(i);
      if(CheckPointer(params)!=POINTER_INVALID)
         delete params;
      params=new CParamsBase(xStrategy);
      if(!params.IsValid() || (params.Symbol()!=Symbol() && load_curr_symbol))
         continue;
      CStrategy *str=CStrategy::GetStrategy(params.Name());
      if(str==NULL)
         continue;
      str.ExpertMagic(params.Magic());
      str.ExpertSymbol(params.Symbol());
      str.Timeframe(params.Timeframe());
      str.ExpertName(params.Name());
      string name=str.ExpertName();
      CXmlElement *xml_params=xStrategy.GetChild("Params");
      if(xml_params!=NULL)
         str.ParseXmlParams(xml_params);
      CXmlElement *xml_mm=xStrategy.GetChild("MoneyManagment");
      if(xml_mm!=NULL)
        {
         if(!str.MM.ParseByXml(xml_mm))
           {
            string text="Strategy "+str.ExpertName()+" (Magic: "+(string)str.ExpertMagic()+") load MM from XML failed";
            CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
            Log.AddMessage(msg);
           }
        }
      CXmlElement *xml_regim=xStrategy.GetChild("TradeStateStart");
      if(xml_regim!=NULL)
        {
         string regim=xml_regim.GetText();
         if(regim=="BuyAndSell")
            str.TradeState(TRADE_BUY_AND_SELL);
         else if(regim=="BuyOnly")
            str.TradeState(TRADE_BUY_ONLY);
         else if(regim=="SellOnly")
            str.TradeState(TRADE_SELL_ONLY);
         else if(regim=="Stop")
            str.TradeState(TRADE_STOP);
         else if(regim=="Wait")
            str.TradeState(TRADE_WAIT);
         else if(regim=="NoNewEntry")
            str.TradeState(TRADE_NO_NEW_ENTRY);
         else
           {
            string text="For strategy "+str.ExpertName()+" (Magic: "+(string)str.ExpertMagic()+
                        ") set not correctly trade state: "+regim;
            CMessage *msg=new CMessage(MESSAGE_WARNING,__FUNCTION__,text);
            Log.AddMessage(msg);
           }
        }
      AddStrategy(str);
     }
   if(CheckPointer(params)!=POINTER_INVALID)
      delete params;
  }
//+------------------------------------------------------------------+
//| Parses XML strategies                                            |
//+------------------------------------------------------------------+
void CStrategyList::OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   CEvent *event=NULL;
   switch(id)
     {
      case CHARTEVENT_OBJECT_CLICK:
         event=new CEventChartObjClick(sparam);
         break;
      case CHARTEVENT_MOUSE_MOVE:
         event=new CEventChartMouseMove(lparam,(long)dparam,(int)sparam);
         break;
      case CHARTEVENT_OBJECT_ENDEDIT:
         event=new CEventChartEndEdit(sparam);
         break;
      case CHARTEVENT_CUSTOM+EVENT_CHART_LIST_CHANGED:
         event=new CEventChartListChanged(sparam);
         break;
     }
   if(event!=NULL)
     {
      StrButton.Event(event);
      delete event;
     }
   ChartRedraw();
  }

CStrategyList Manager;
//+------------------------------------------------------------------+
