#ifndef sg_udp_probe_cal_h_
#define sg_udp_probe_cal_h_
#include "rtwtypes.h"

/* Storage class 'PageSwitching', for system '<Root>' */
struct sg_udp_probe_cal_type {
  uint8_T UDP_1024_fmAddress[4];       /* Computed Parameter: UDP_1024_fmAddress
                                        * Referenced by: '<Root>/UDP_1024'
                                        */
  uint8_T UDP_5000_fmAddress[4];       /* Computed Parameter: UDP_5000_fmAddress
                                        * Referenced by: '<Root>/UDP_5000'
                                        */
  uint8_T UDP_50000_fmAddress[4];     /* Computed Parameter: UDP_50000_fmAddress
                                       * Referenced by: '<Root>/UDP_50000'
                                       */
  uint8_T UDP_50001_fmAddress[4];     /* Computed Parameter: UDP_50001_fmAddress
                                       * Referenced by: '<Root>/UDP_50001'
                                       */
  uint8_T UDP_8080_fmAddress[4];       /* Computed Parameter: UDP_8080_fmAddress
                                        * Referenced by: '<Root>/UDP_8080'
                                        */
};

/* Storage class 'PageSwitching' */
extern sg_udp_probe_cal_type sg_udp_probe_cal_impl;
extern sg_udp_probe_cal_type *sg_udp_probe_cal;

#endif                                 /* sg_udp_probe_cal_h_ */
