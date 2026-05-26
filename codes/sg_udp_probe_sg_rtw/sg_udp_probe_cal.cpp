#include "sg_udp_probe_cal.h"
#include "sg_udp_probe.h"

/* Storage class 'PageSwitching' */
sg_udp_probe_cal_type sg_udp_probe_cal_impl = {
  /* Computed Parameter: UDP_1024_fmAddress
   * Referenced by: '<Root>/UDP_1024'
   */
  { 0U, 0U, 0U, 0U },

  /* Computed Parameter: UDP_5000_fmAddress
   * Referenced by: '<Root>/UDP_5000'
   */
  { 0U, 0U, 0U, 0U },

  /* Computed Parameter: UDP_50000_fmAddress
   * Referenced by: '<Root>/UDP_50000'
   */
  { 0U, 0U, 0U, 0U },

  /* Computed Parameter: UDP_50001_fmAddress
   * Referenced by: '<Root>/UDP_50001'
   */
  { 0U, 0U, 0U, 0U },

  /* Computed Parameter: UDP_8080_fmAddress
   * Referenced by: '<Root>/UDP_8080'
   */
  { 0U, 0U, 0U, 0U }
};

sg_udp_probe_cal_type *sg_udp_probe_cal = &sg_udp_probe_cal_impl;
