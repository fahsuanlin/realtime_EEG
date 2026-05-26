/*
 * sg_eeg_20ch_rt.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "sg_eeg_20ch_rt".
 *
 * Model version              : 1.5
 * Simulink Coder version : 25.1 (R2025a) 21-Nov-2024
 * C++ source code generated on : Tue Feb 24 16:36:39 2026
 *
 * Target selection: speedgoat.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "sg_eeg_20ch_rt.h"
#include "rtwtypes.h"
#include "sg_eeg_20ch_rt_cal.h"
#include <cstring>
#include "sg_eeg_20ch_rt_private.h"
#include <cmath>

/* Named constants for MATLAB Function: '<Root>/Decode20' */
const int32_T sg_eeg_20ch_rt_CALL_EVENT = -1;

/* Block signals (default storage) */
B_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_B;

/* Block states (default storage) */
DW_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_DW;

/* External outputs (root outports fed by signals with default storage) */
ExtY_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_Y;

/* Real-time model */
RT_MODEL_sg_eeg_20ch_rt_T sg_eeg_20ch_rt_M_ = RT_MODEL_sg_eeg_20ch_rt_T();
RT_MODEL_sg_eeg_20ch_rt_T *const sg_eeg_20ch_rt_M = &sg_eeg_20ch_rt_M_;
real_T rt_roundd_snf(real_T u)
{
  real_T y;
  if (std::abs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = std::floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = std::ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

/* Model step function */
void sg_eeg_20ch_rt_step(void)
{
  real_T tmp;
  int32_T i;
  int32_T idx;
  int32_T qY;
  uint32_T u24;
  uint32_T x;

  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP Receive' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_eeg_20ch_rt_DW.UDPReceive_PWORK[0]);
      char *buffer = (char *)sg_eeg_20ch_rt_DW.UDPReceive_PWORK[1];
      memset(buffer,0,1228);
      void *dataPort = &sg_eeg_20ch_rt_B.UDPReceive_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_eeg_20ch_rt_cal->UDPReceive_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !0,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_eeg_20ch_rt_B.UDPReceive_o2 = 0;
        } else {
          sg_eeg_20ch_rt_B.UDPReceive_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,1228);
        }
      } else {
        sg_eeg_20ch_rt_B.UDPReceive_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_eeg_20ch_rt_M, eMsg.c_str());
      rtmSetStopRequested(sg_eeg_20ch_rt_M, 1);
      ;
    }
  }

  /* MATLAB Function: '<Root>/Decode20' */
  sg_eeg_20ch_rt_DW.sfEvent = sg_eeg_20ch_rt_CALL_EVENT;
  std::memset(&sg_eeg_20ch_rt_B.y[0], 0, 20U * sizeof(real_T));
  tmp = rt_roundd_snf(sg_eeg_20ch_rt_B.UDPReceive_o2);
  if (tmp < 2.147483648E+9) {
    if (tmp >= -2.147483648E+9) {
      i = static_cast<int32_T>(tmp);
    } else {
      i = MIN_int32_T;
    }
  } else {
    i = MAX_int32_T;
  }

  i -= 28;
  if (i + 28 >= 88) {
    u24 = static_cast<uint32_T>(i) / 60U;
    if (i - static_cast<int32_T>(u24) * 60 == 0) {
      x = (static_cast<uint32_T>(i) - u24 * 60U) + 28U;
      if (x + 4294967268U >= 30U) {
        u24++;
      }

      i = (static_cast<int32_T>(u24) - 1) * 60 + 29;
      if (i > 2147483587) {
        qY = MAX_int32_T;
      } else {
        qY = i + 60;
      }

      if (qY - 1 <= 1228) {
        for (qY = 0; qY < 20; qY++) {
          idx = qY * 3;
          if ((i < 0) && (idx < MIN_int32_T - i)) {
            idx = MIN_int32_T;
          } else if ((i > 0) && (idx > MAX_int32_T - i)) {
            idx = MAX_int32_T;
          } else {
            idx += i;
          }

          u24 = ((static_cast<uint32_T>(sg_eeg_20ch_rt_B.UDPReceive_o1[idx - 1])
                  << 16) + (static_cast<uint32_T>
                            (sg_eeg_20ch_rt_B.UDPReceive_o1[idx]) << 8)) +
            sg_eeg_20ch_rt_B.UDPReceive_o1[idx + 1];
          if (u24 >= 8388608U) {
            idx = 0;
          } else {
            idx = static_cast<int32_T>(u24);
          }

          sg_eeg_20ch_rt_B.y[qY] = idx;
        }
      }
    }
  }

  /* End of MATLAB Function: '<Root>/Decode20' */

  /* Outport: '<Root>/EEG20_Out' */
  std::memcpy(&sg_eeg_20ch_rt_Y.EEG20_Out[0], &sg_eeg_20ch_rt_B.y[0], 20U *
              sizeof(real_T));

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++sg_eeg_20ch_rt_M->Timing.clockTick0)) {
    ++sg_eeg_20ch_rt_M->Timing.clockTickH0;
  }

  sg_eeg_20ch_rt_M->Timing.taskTime0 = sg_eeg_20ch_rt_M->Timing.clockTick0 *
    sg_eeg_20ch_rt_M->Timing.stepSize0 + sg_eeg_20ch_rt_M->Timing.clockTickH0 *
    sg_eeg_20ch_rt_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void sg_eeg_20ch_rt_initialize(void)
{
  /* Registration code */
  sg_eeg_20ch_rt_M->Timing.stepSize0 = 0.001;

  /* block I/O */
  (void) std::memset((static_cast<void *>(&sg_eeg_20ch_rt_B)), 0,
                     sizeof(B_sg_eeg_20ch_rt_T));

  /* states (dwork) */
  (void) std::memset(static_cast<void *>(&sg_eeg_20ch_rt_DW), 0,
                     sizeof(DW_sg_eeg_20ch_rt_T));

  /* external outputs */
  (void)std::memset(&sg_eeg_20ch_rt_Y, 0, sizeof(ExtY_sg_eeg_20ch_rt_T));

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP Receive' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "192.168.200.1",50000U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_eeg_20ch_rt_DW.UDPReceive_IWORK[0] = 1228;
      sg_eeg_20ch_rt_DW.UDPReceive_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_eeg_20ch_rt_DW.UDPReceive_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_eeg_20ch_rt_M, eMsg.c_str());
      rtmSetStopRequested(sg_eeg_20ch_rt_M, 1);
      ;
    }
  }

  /* SystemInitialize for MATLAB Function: '<Root>/Decode20' */
  sg_eeg_20ch_rt_DW.sfEvent = sg_eeg_20ch_rt_CALL_EVENT;
}

/* Model terminate function */
void sg_eeg_20ch_rt_terminate(void)
{
  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP Receive' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("192.168.200.1",50000U);
    char *buffer = (char *)sg_eeg_20ch_rt_DW.UDPReceive_PWORK[1];
    if (buffer)
      free(buffer);
  }
}
