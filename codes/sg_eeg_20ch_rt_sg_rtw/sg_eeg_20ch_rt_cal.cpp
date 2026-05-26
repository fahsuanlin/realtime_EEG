#include "sg_eeg_20ch_rt_cal.h"
#include "sg_eeg_20ch_rt.h"

/* Storage class 'PageSwitching' */
sg_eeg_20ch_rt_cal_type sg_eeg_20ch_rt_cal_impl = {
  /* Computed Parameter: UDPReceive_fmAddress
   * Referenced by: '<Root>/UDP Receive'
   */
  { 192U, 168U, 200U, 200U }
};

sg_eeg_20ch_rt_cal_type *sg_eeg_20ch_rt_cal = &sg_eeg_20ch_rt_cal_impl;
