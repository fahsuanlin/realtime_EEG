/*
 * sg_udp_probe.cpp
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "sg_udp_probe".
 *
 * Model version              : 1.1
 * Simulink Coder version : 25.1 (R2025a) 21-Nov-2024
 * C++ source code generated on : Tue Feb 24 15:26:22 2026
 *
 * Target selection: speedgoat.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#include "sg_udp_probe.h"
#include "sg_udp_probe_cal.h"
#include <cstring>

/* Block signals (default storage) */
B_sg_udp_probe_T sg_udp_probe_B;

/* Block states (default storage) */
DW_sg_udp_probe_T sg_udp_probe_DW;

/* Real-time model */
RT_MODEL_sg_udp_probe_T sg_udp_probe_M_ = RT_MODEL_sg_udp_probe_T();
RT_MODEL_sg_udp_probe_T *const sg_udp_probe_M = &sg_udp_probe_M_;

/* Model step function */
void sg_udp_probe_step(void)
{
  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP_1024' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_udp_probe_DW.UDP_1024_PWORK[0]);
      char *buffer = (char *)sg_udp_probe_DW.UDP_1024_PWORK[1];
      memset(buffer,0,2048);
      void *dataPort = &sg_udp_probe_B.UDP_1024_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_udp_probe_cal->UDP_1024_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !1,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_udp_probe_B.UDP_1024_o2 = 0;
        } else {
          sg_udp_probe_B.UDP_1024_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,2048);
        }
      } else {
        sg_udp_probe_B.UDP_1024_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP_5000' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_udp_probe_DW.UDP_5000_PWORK[0]);
      char *buffer = (char *)sg_udp_probe_DW.UDP_5000_PWORK[1];
      memset(buffer,0,2048);
      void *dataPort = &sg_udp_probe_B.UDP_5000_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_udp_probe_cal->UDP_5000_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !1,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_udp_probe_B.UDP_5000_o2 = 0;
        } else {
          sg_udp_probe_B.UDP_5000_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,2048);
        }
      } else {
        sg_udp_probe_B.UDP_5000_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP_50000' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_udp_probe_DW.UDP_50000_PWORK[0]);
      char *buffer = (char *)sg_udp_probe_DW.UDP_50000_PWORK[1];
      memset(buffer,0,2048);
      void *dataPort = &sg_udp_probe_B.UDP_50000_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_udp_probe_cal->UDP_50000_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !1,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_udp_probe_B.UDP_50000_o2 = 0;
        } else {
          sg_udp_probe_B.UDP_50000_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,2048);
        }
      } else {
        sg_udp_probe_B.UDP_50000_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP_50001' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_udp_probe_DW.UDP_50001_PWORK[0]);
      char *buffer = (char *)sg_udp_probe_DW.UDP_50001_PWORK[1];
      memset(buffer,0,2048);
      void *dataPort = &sg_udp_probe_B.UDP_50001_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_udp_probe_cal->UDP_50001_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !1,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_udp_probe_B.UDP_50001_o2 = 0;
        } else {
          sg_udp_probe_B.UDP_50001_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,2048);
        }
      } else {
        sg_udp_probe_B.UDP_50001_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* S-Function (slrealtimeUDPReceive): '<Root>/UDP_8080' */
  {
    try {
      slrealtime::ip::udp::Socket *udpSock = reinterpret_cast<slrealtime::ip::
        udp::Socket*>(sg_udp_probe_DW.UDP_8080_PWORK[0]);
      char *buffer = (char *)sg_udp_probe_DW.UDP_8080_PWORK[1];
      memset(buffer,0,2048);
      void *dataPort = &sg_udp_probe_B.UDP_8080_o1[0];
      int_T numBytesAvail = (int_T)(udpSock->bytesToRead());
      if (numBytesAvail > 0) {
        uint8_t* fmAddArg = (uint8_t *)sg_udp_probe_cal->UDP_8080_fmAddress;
        size_t num_bytesRcvd = (size_t)(udpSock->receive(buffer,( numBytesAvail<
          65507 )? numBytesAvail:65507, !1,fmAddArg));
        if (num_bytesRcvd == 0) {
          sg_udp_probe_B.UDP_8080_o2 = 0;
        } else {
          sg_udp_probe_B.UDP_8080_o2 = (double)num_bytesRcvd;
          memcpy(dataPort,(void*)buffer,2048);
        }
      } else {
        sg_udp_probe_B.UDP_8080_o2 = 0;
      }
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  if (!(++sg_udp_probe_M->Timing.clockTick0)) {
    ++sg_udp_probe_M->Timing.clockTickH0;
  }

  sg_udp_probe_M->Timing.taskTime0 = sg_udp_probe_M->Timing.clockTick0 *
    sg_udp_probe_M->Timing.stepSize0 + sg_udp_probe_M->Timing.clockTickH0 *
    sg_udp_probe_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void sg_udp_probe_initialize(void)
{
  /* Registration code */
  sg_udp_probe_M->Timing.stepSize0 = 0.001;

  /* block I/O */
  (void) std::memset((static_cast<void *>(&sg_udp_probe_B)), 0,
                     sizeof(B_sg_udp_probe_T));

  /* states (dwork) */
  (void) std::memset(static_cast<void *>(&sg_udp_probe_DW), 0,
                     sizeof(DW_sg_udp_probe_T));

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP_1024' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "0.0.0.0",1024U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_udp_probe_DW.UDP_1024_IWORK[0] = 2048;
      sg_udp_probe_DW.UDP_1024_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_udp_probe_DW.UDP_1024_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP_5000' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "0.0.0.0",5000U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_udp_probe_DW.UDP_5000_IWORK[0] = 2048;
      sg_udp_probe_DW.UDP_5000_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_udp_probe_DW.UDP_5000_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP_50000' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "0.0.0.0",50000U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_udp_probe_DW.UDP_50000_IWORK[0] = 2048;
      sg_udp_probe_DW.UDP_50000_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_udp_probe_DW.UDP_50000_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP_50001' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "0.0.0.0",50001U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_udp_probe_DW.UDP_50001_IWORK[0] = 2048;
      sg_udp_probe_DW.UDP_50001_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_udp_probe_DW.UDP_50001_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }

  /* Start for S-Function (slrealtimeUDPReceive): '<Root>/UDP_8080' */
  {
    try {
      uint8_t *tempAddr = nullptr;
      uint8_t *tempInterface = nullptr;
      slrealtime::ip::udp::Socket *udpSock = (slrealtime::ip::udp::Socket *)
        slrealtime::ip::SocketFactory::createSocket(slrealtime::ip::SocketType::
        UDP, "0.0.0.0",8080U);
      if (tempAddr)
        delete tempAddr;
      if (tempInterface)
        delete tempInterface;
      sg_udp_probe_DW.UDP_8080_IWORK[0] = 2048;
      sg_udp_probe_DW.UDP_8080_PWORK[0] = reinterpret_cast<void*>(udpSock);
      char *buffer = (char *)calloc(65507,sizeof(char));
      sg_udp_probe_DW.UDP_8080_PWORK[1] = (void*)buffer;
    } catch (std::exception& e) {
      std::string tmp = std::string(e.what());
      static std::string eMsg = tmp;
      rtmSetErrorStatus(sg_udp_probe_M, eMsg.c_str());
      rtmSetStopRequested(sg_udp_probe_M, 1);
      ;
    }
  }
}

/* Model terminate function */
void sg_udp_probe_terminate(void)
{
  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP_1024' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("0.0.0.0",1024U);
    char *buffer = (char *)sg_udp_probe_DW.UDP_1024_PWORK[1];
    if (buffer)
      free(buffer);
  }

  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP_5000' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("0.0.0.0",5000U);
    char *buffer = (char *)sg_udp_probe_DW.UDP_5000_PWORK[1];
    if (buffer)
      free(buffer);
  }

  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP_50000' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("0.0.0.0",50000U);
    char *buffer = (char *)sg_udp_probe_DW.UDP_50000_PWORK[1];
    if (buffer)
      free(buffer);
  }

  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP_50001' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("0.0.0.0",50001U);
    char *buffer = (char *)sg_udp_probe_DW.UDP_50001_PWORK[1];
    if (buffer)
      free(buffer);
  }

  /* Terminate for S-Function (slrealtimeUDPReceive): '<Root>/UDP_8080' */
  {
    slrealtime::ip::SocketFactory::releaseSocket("0.0.0.0",8080U);
    char *buffer = (char *)sg_udp_probe_DW.UDP_8080_PWORK[1];
    if (buffer)
      free(buffer);
  }
}
