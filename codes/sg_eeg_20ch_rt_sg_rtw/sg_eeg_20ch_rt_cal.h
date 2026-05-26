#ifndef sg_eeg_20ch_rt_cal_h_
#define sg_eeg_20ch_rt_cal_h_
#include "rtwtypes.h"

/* Storage class 'PageSwitching', for system '<Root>' */
struct sg_eeg_20ch_rt_cal_type {
  uint8_T UDPReceive_fmAddress[4];   /* Computed Parameter: UDPReceive_fmAddress
                                      * Referenced by: '<Root>/UDP Receive'
                                      */
};

/* Storage class 'PageSwitching' */
extern sg_eeg_20ch_rt_cal_type sg_eeg_20ch_rt_cal_impl;
extern sg_eeg_20ch_rt_cal_type *sg_eeg_20ch_rt_cal;

#endif                                 /* sg_eeg_20ch_rt_cal_h_ */
