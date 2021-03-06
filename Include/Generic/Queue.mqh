//+------------------------------------------------------------------+
//|                                                        Queue.mqh |
//|                   Copyright 2016-2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Generic\Interfaces\ICollection.mqh>
#include <Generic\Internal\ArrayFunction.mqh>
#include <Generic\Internal\EqualFunction.mqh>
//+------------------------------------------------------------------+
//| Class CQueue<T>.                                                 |
//| Usage: Represents a first-in, first-out collection of objects.   |
//+------------------------------------------------------------------+
template<typename T>
class CQueue: public ICollection<T>
  {
protected:
   T                 m_array[];
   int               m_size;
   int               m_head;              // first valid element in the queue
   int               m_tail;              // last valid element in the queue
   const int         m_default_capacity;

public:
                     CQueue(void);
                     CQueue(const int capacity);
                     CQueue(ICollection<T>&collection[]);
                     CQueue(T &array[]);
                    ~CQueue(void);
   //--- methods of filling data 
   bool              Add(T value);
   bool              Enqueue(T value);
   //--- methods of access to protected data
   int               Count(void);
   bool              Contains(T item);
   void              TrimExcess(void);
   //--- methods of copy data from collection   
   int               CopyTo(T &dst_array[],const int dst_start=0);
   //--- methods of cleaning and removing
   void              Clear(void);
   bool              Remove(T item);
   T                 Dequeue(void);
   T                 Peek(void);

private:
   void              SetCapacity(const int capacity);
  };
//+------------------------------------------------------------------+
//| Initializes a new instance of the CQueue<T> class that is empty  |
//| and has the default initial capacity.                            |
//+------------------------------------------------------------------+
template<typename T>
CQueue::CQueue(void): m_default_capacity(4),
                      m_size(0),
                      m_head(0),
                      m_tail(0)
  {
   ArrayResize(m_array,m_default_capacity);
  }
//+------------------------------------------------------------------+
//| Initializes a new instance of the CQueue<T> class that is empty  |
//| and has the specified initial capacity or the default initial    |
//| capacity, whichever is greater.                                  |
//+------------------------------------------------------------------+
template<typename T>
CQueue::CQueue(const int capacity): m_default_capacity(4),
                                    m_size(0),
                                    m_head(0),
                                    m_tail(0)
  {
   ArrayResize(m_array,capacity);
  }
//+------------------------------------------------------------------+
//| Initializes a new instance of the CQueue<T> class that contains  |
//| elements copied from the specified array and has sufficient      |
//| capacity to accommodate the number of elements copied.           |
//+------------------------------------------------------------------+
template<typename T>
CQueue::CQueue(T &array[]): m_default_capacity(4),
                            m_head(0)
  {
   m_size=ArrayCopy(m_array,array);
//--- set tail
   m_tail=m_size;
   if(m_size%2==1)
      ArrayResize(m_array,m_size+1);
  }
//+------------------------------------------------------------------+
//| Initializes a new instance of the CQueue<T> class that contains  |
//| elements copied from the specified collection and has sufficient |
//| capacity to accommodate the number of elements copied.           |
//+------------------------------------------------------------------+
template<typename T>
CQueue::CQueue(ICollection<T>*collection): m_default_capacity(4),
                                           m_head(0)
  {
//--- check collection   
   if(CheckPointer(collection)!=POINTER_INVALID)
      m_size=collection.CopyTo(m_array);
   else
      m_size=0;
//--- set tail
   m_tail=m_size;
   if(m_size%2==1)
      ArrayResize(m_array,m_size+1);
  }
//+------------------------------------------------------------------+
//| Destructor.                                                      |
//+------------------------------------------------------------------+
template<typename T>
CQueue::~CQueue(void)
  {
  }
//+------------------------------------------------------------------+
//| Inserts an value at the top of the CQueue<T>.                    |
//+------------------------------------------------------------------+
template<typename T>
bool CQueue::Add(T value)
  {
   return Enqueue(value);
  }
//+------------------------------------------------------------------+
//| Gets the number of elements.                                     |
//+------------------------------------------------------------------+
template<typename T>
int CQueue::Count(void)
  {
   return(m_size);
  }
//+------------------------------------------------------------------+
//| Removes all values from the CQueue<T>.                           |
//+------------------------------------------------------------------+
template<typename T>
bool CQueue::Contains(T item)
  {
   int count=m_size;
//--- try to find item in array
   while(count-->0)
     {
      //--- use default equality function
      if(::Equals(m_array[count],item))
         return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Sets the capacity to the actual number of elements in the queue,  |
//| if that number is less than a threshold value.                   |
//+------------------------------------------------------------------+
template<typename T>
void CQueue::TrimExcess(void)
  {
//--- calculate threshold value
   int threshold=(int)(((double)ArraySize(m_array))*0.9);
//--- set a сapacity equal to the size
   if(m_size<threshold)
      SetCapacity(m_size);
  }
//+------------------------------------------------------------------+
//| Copies a range of elements from the queue to a compatible        |
//| one-dimensional array.                                           |
//+------------------------------------------------------------------+
template<typename T>
int CQueue::CopyTo(T &dst_array[],const int dst_start=0)
  {

//--- resize array
   if(dst_start+m_size>ArraySize(dst_array))
      ArrayResize(dst_array,dst_start+m_size);
//--- check tail and head
   if(m_tail>m_head)
     {
      //--- copying an array from head to tail
      int num_copied=ArrayCopy(dst_array,m_array,dst_start,m_head,m_tail);
      //--- return number of copied elements
      return(num_copied);
     }
   else
     {
      //--- copying an array from head to end
      int num_copied=ArrayCopy(dst_array,m_array,dst_start,m_head,m_size-m_tail);
      //--- copying an array from beginning to tail
      num_copied+=ArrayCopy(dst_array,m_array,dst_start+num_copied,0,m_tail);
      //--- return number of copied elements
      return(num_copied);
     }
  }
//+------------------------------------------------------------------+
//| Removes all values from the CQueue<T>.                           |
//+------------------------------------------------------------------+
template<typename T>
void CQueue::Clear(void)
  {
//--- check current size
   if(m_size>0)
     {
      ArrayFree(m_array);
      m_size=0;
      m_head=0;
      m_tail=0;
     }
  }
//+------------------------------------------------------------------+
//| Removes the first occurrence of a specific value from the stack. |
//+------------------------------------------------------------------+
template<typename T>
bool CQueue::Remove(T item)
  {
//--- first try to find index of item 
//--- find from head to end
   int index=ArrayIndexOf(m_array,item,m_head,m_size-m_head);
   if(index!=-1)
     {
      //--- shift the values to the left
      ArrayCopy(m_array,m_array,index,index+1);
      //--- decrement size
      m_size--;
      return(true);
     }
//--- second try to find index of item 
//--- find from start to tail
   index=ArrayIndexOf(m_array,item,0,m_tail+1);
   if(index!=-1)
     {
      //--- shift the values to the right
      ArrayCopy(m_array,m_array,index,index+1);
      //--- decrement size
      m_size--;
      //--- decrement head and tail
      m_tail--;
      m_head--;
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Adds an value to the end of the CQueue<T>.                       |
//+------------------------------------------------------------------+
template<typename T>
bool CQueue::Enqueue(T value)
  {
//--- check current size
   if(m_size==ArraySize(m_array))
     {
      //--- calculate new capacity
      int new_capacity=(int)((long)ArraySize(m_array) *(long)2);
      if(new_capacity<ArraySize(m_array)+4)
         new_capacity=ArraySize(m_array)+4;
      //--- set new capacity        
      SetCapacity(new_capacity);
     }
//--- add value to the end
   m_array[m_tail]=value;
//--- increase size and recalculate tail
   m_size++;
   m_tail=(m_tail+1)%ArraySize(m_array);
   return(true);
  }
//+------------------------------------------------------------------+
//| Removes and returns the value at the beginning of the CQueue<T>. |
//+------------------------------------------------------------------+
template<typename T>
T CQueue::Dequeue(void)
  {
//--- get value from the end  
   T removed=m_array[m_head];
//--- decrement size and recalculate head
   m_head=(m_head+1)%ArraySize(m_array);
   m_size--;
   return(removed);
  }
//+------------------------------------------------------------------+
//| Returns the value at the beginning of the CQueue<T> without      |
//| removing.                                                        |
//+------------------------------------------------------------------+
template<typename T>
T CQueue::Peek(void)
  {
//--- get value from the end  
   return(m_array[m_head]);
  }
//+------------------------------------------------------------------+
//| Grows or shrinks the buffer to hold capacity values.             |
//+------------------------------------------------------------------+
template<typename T>
void CQueue::SetCapacity(const int capacity)
  {
   int size=ArraySize(m_array);
//--- create a new array array for temporary storage   
   T new_array[];
   ArrayResize(new_array,capacity);
//--- check size
   if(m_size>0)
     {
      if(m_head<m_tail)
        {
         //--- shift the values to the left
         ArrayCopy(new_array,m_array,0,m_head,m_size);
        }
      else
        {
         //--- shift the values to the left
         ArrayCopy(new_array,m_array,0,m_head,size-m_head);
         //--- shift the values to the right
         ArrayCopy(new_array,m_array,size-m_head,0,m_tail);
        }
     }
//---
   ArrayCopy(m_array,new_array);
//--- set new tail and head
   m_head=0;
   m_tail=(m_size == capacity) ? 0 : m_size;
  }
//+------------------------------------------------------------------+