#include "rte_sg_eeg_20ch_rt_parameters.h"
#include "sg_eeg_20ch_rt.h"
#include "sg_eeg_20ch_rt_cal.h"

extern sg_eeg_20ch_rt_cal_type sg_eeg_20ch_rt_cal_impl;
namespace slrealtime
{
  /* Description of SEGMENTS */
  SegmentVector segmentInfo {
    { (void*)&sg_eeg_20ch_rt_cal_impl, (void**)&sg_eeg_20ch_rt_cal, sizeof
      (sg_eeg_20ch_rt_cal_type), 2 }
  };

  SegmentVector &getSegmentVector(void)
  {
    return segmentInfo;
  }
}                                      // slrealtime
