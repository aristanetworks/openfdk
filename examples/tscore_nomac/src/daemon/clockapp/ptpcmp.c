//------------------------------------------------------------------------------
// Copyright (c) 2021-2023 Arista Networks, Inc. All rights reserved.
//------------------------------------------------------------------------------
// Author:
//   fdk-support@arista.com
//
// Description:
//   Licensed under BSD 3-clause license:
//     https://opensource.org/licenses/BSD-3-Clause
//
// Tags:
//   license-bsd-3-clause
//
//------------------------------------------------------------------------------

#include <assert.h>
#include <sched.h>
#include <time.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/io.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/resource.h>

#include <linux/ethtool.h>
#include <linux/ethtool.h>
#include <linux/sockios.h>

#include <net/if.h>

#include <netinet/in.h>

#define CLOCKFD 3
#define FD_TO_CLOCKID(fd)   ((~(clockid_t) (fd) << 3) | CLOCKFD)
#define CLOCKID_TO_FD(clk)  ((unsigned int) ~((clk) >> 3))

void
close_ptpclock(int clockid)
{
    int fd = CLOCKID_TO_FD(clockid);
    close(fd);
}


int
open_ptpclock(const char *interface)
{
    assert(interface);
    char clockpath[65] = {0};

    int err;
    struct ethtool_ts_info info;
    struct ifreq ifr;

    int fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (!fd) {
        perror("socket");
        return -1;
    }

    memset(&ifr, 0, sizeof(ifr));
    memset(&info, 0, sizeof(info));

    info.cmd = ETHTOOL_GET_TS_INFO;
    strncpy(ifr.ifr_name, interface, IFNAMSIZ - 1);
    ifr.ifr_data = (char *) &info;
    err = ioctl(fd, SIOCETHTOOL, &ifr);
    close(fd);
    if (err < 0) {
        perror("Unable to get timestamp info");
        return -1;

    }
    snprintf(clockpath, 64, "/dev/ptp%d", info.phc_index);
    int ptpfd = open(clockpath, O_RDWR);
    return FD_TO_CLOCKID(ptpfd);
}


int raise_priority(void) {
    int process;
    process = setpriority(PRIO_PROCESS, 0, -20);
    if ( (process) > 0) {
        printf("Couldn't set niceness\n");
    }

    const struct sched_param param = {
        .sched_priority = sched_get_priority_max(SCHED_FIFO),
    };

    errno = 0;
    int r = sched_setscheduler(0, SCHED_FIFO, &param);
    if (r != 0) {
        printf("Couldn't set sched_fifo / prio_max\n");
        perror("setsched");
    }

    return r;
}

static inline uint64_t
read_clock(int clockid)
{
#define BILLION     1000000000UL
    struct timespec t;
    clock_gettime(clockid, &t);
    return t.tv_sec*BILLION + t.tv_nsec;
}

int timed_strobe(int clockid, uint64_t *t1, uint64_t *t2)
{
    struct timespec ts1, ts2;


    outb(0x00, 0x500 + 0x88);

    clock_gettime(clockid, &ts1);
    outb(0x80, 0x500 + 0x88);
    clock_gettime(clockid, &ts2);

    *t1 = ts1.tv_sec*BILLION + ts1.tv_nsec;
    *t2 = ts2.tv_sec*BILLION + ts2.tv_nsec;

    return 0;
}
