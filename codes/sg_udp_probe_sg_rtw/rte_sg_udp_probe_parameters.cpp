#include "rte_sg_udp_probe_parameters.h"
#include "sg_udp_probe.h"
#include "sg_udp_probe_cal.h"

extern sg_udp_probe_cal_type sg_udp_probe_cal_impl;
namespace slrealtime
{
  /* Description of SEGMENTS */
  SegmentVector segmentInfo {
    { (void*)&sg_udp_probe_cal_impl, (void**)&sg_udp_probe_cal, sizeof
      (sg_udp_probe_cal_type), 2 }
  };

  SegmentVector &getSegmentVector(void)
  {
    return segmentInfo;
  }
}                                      // slrealtime
