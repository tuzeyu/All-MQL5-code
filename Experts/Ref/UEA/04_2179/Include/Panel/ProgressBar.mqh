//+------------------------------------------------------------------+
//|                                                  ProgressBar.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "http://www.mql5.com"
#include "ElChart.mqh"
#include <Panel\Events\EventChartPBRefresh.mqh>
//+------------------------------------------------------------------+
//| Graphic element ProgressBar                                      |
//+------------------------------------------------------------------+
class CElProgressBar : public CElChart
  {
private:
   CElChart          m_progress;         // Filler of the progress bar
   CElChart          m_per_label;        // Progress in %
   int               m_progress_bar_id;  // 
   virtual void      OnXCoordChange(void);
   virtual void      OnYCoordChange(void);
   virtual void      OnHeightChange(void);
   virtual void      OnWidthChange(void);
public:
                     CElProgressBar(void);
   virtual void      Event(CEvent *event);
   void              SetPercent(double percent);
   void              ProgressBarID(int id);
   int               ProgressBarID(void);

  };
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
CElProgressBar::CElProgressBar(void) : CElChart(OBJ_EDIT),
                                       m_progress(OBJ_EDIT),
                                       m_per_label(OBJ_EDIT)
  {
   m_progress.BackgroundColor(clrLime);
   m_progress.BorderColor(clrLime);
   m_progress.Width(0);
   m_per_label.BorderColor(clrNONE);
   m_per_label.BackgroundColor(clrNONE);
   m_per_label.TextSize(8);
   m_per_label.TextFont("Arial Rounded MT Bold");
   m_per_label.Width(50);
   SetPercent(0.0);
   m_elements.Add(GetPointer(m_progress));
   m_elements.Add(GetPointer(m_per_label));
  }
//+------------------------------------------------------------------+
//| Change the X coordinate of the filler to match changes           |
//| of the parent window                                             |
//+------------------------------------------------------------------+
void CElProgressBar::OnXCoordChange(void)
  {
   m_progress.XCoord(XCoord()+2);
  }
//+------------------------------------------------------------------+
//| Change the Y coordinate of the filler after the changes          |
//| of the parent window                                             |
//+------------------------------------------------------------------+
void CElProgressBar::OnYCoordChange(void)
  {
   m_progress.YCoord(YCoord()+1);
   m_per_label.YCoord(YCoord()+3);
  }
//+------------------------------------------------------------------+
//| Change the hight of the bar filler after the changes             |
//| of the parent window                                             |
//+------------------------------------------------------------------+
void CElProgressBar::OnHeightChange(void)
  {
   m_progress.Height(Height()-2);
   m_per_label.Height(Height()-6);
  }
//+------------------------------------------------------------------+
//| Changing the width of the bar filler position after the changes  |
//| of the parent window                                             |
//+------------------------------------------------------------------+
void CElProgressBar::OnWidthChange(void)
  {
   m_per_label.XCoord(XCoord()+(long)(Width()/2.0)-25);
  }
//+------------------------------------------------------------------+
//| Sets the ID of the progress bar                                  |
//+------------------------------------------------------------------+
void CElProgressBar::ProgressBarID(int id)
  {
   m_progress_bar_id=id;
  }
//+------------------------------------------------------------------+
//| Returns the ID of the progress bar                               |
//+------------------------------------------------------------------+
int CElProgressBar::ProgressBarID(void)
  {
   return m_progress_bar_id;
  }
//+------------------------------------------------------------------+
//| Sets the percent of the progress bar                             |
//+------------------------------------------------------------------+
void CElProgressBar::SetPercent(double percent)
  {
   if(percent < 0.0)
      percent=0.0;
   if(percent > 1.0)
      percent=1.0;
   long w=0;
   if(percent>0.0)
      w=(long)MathRound((Width()-2)*percent);
   m_progress.Width(w-1);
   m_per_label.Text(DoubleToString(percent*100.0,1)+"%");
  }
//+------------------------------------------------------------------+
//| Hooks the event of progress bar update                           |
//+------------------------------------------------------------------+
void CElProgressBar::Event(CEvent *event)
  {
   CElChart::Event(event);
   if(event.EventType()==EVENT_CHART_PBAR_CHANGED)
     {
      CEventChartPBRefresh *pbRefresh=event;
      if(pbRefresh.ProgressBarID()==m_progress_bar_id)
         SetPercent(pbRefresh.ProgressBarValue());
     }
  }
//+------------------------------------------------------------------+
