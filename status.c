/* This is a fork of dwmblocks licensed under GNU General Public License version 2. 
 * See LICENSE file for copyright details. */

#define _POSIX_C_SOURCE 200112L

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <errno.h>
#include <X11/Xlib.h>
#include <pthread.h>
#include <err.h>
#define LENGTH(X) (sizeof(X) / sizeof (X[0]))

typedef struct {
	char* icon;
	char* command;
	unsigned int interval;
	unsigned int signal;
} Module;
typedef struct Thread_ev {
    const Module *module;
    size_t idx;
} Thread_ev;
void sighandler(int num);
void replace(char *str, char old, char new);
void remove_all(char *str, char to_remove);
void getcmds(void);
#ifndef __OpenBSD__
void getsigcmds(int signal);
void setupsignals();
void sighandler(int signum);
#endif
int getstatus(char *str, char *last);
void setroot();
void statusloop();
void termhandler(int signum);


#include "status.h"

static Display *dpy;
static int screen;
static Window root;
static char statusbar[LENGTH(modules)][1024] = {0};
static char statusstr[2][256];
static volatile int statusContinue = 1;
static pthread_mutex_t write_mut = PTHREAD_MUTEX_INITIALIZER;
static void (*writestatus) () = setroot;

void replace(char *str, char old, char new)
{
	for(char * c = str; *c; c++)
		if(*c == old)
			*c = new;
}

void remove_all(char *str, char to_remove) {
	char *read = str;
	char *write = str;
	while (*read) {
		if (*read != to_remove) {
			*write++ = *read;
		}
		++read;
	}
	*write = '\0';
}

void
getcmd(const Module *module, char *output)
{
    FILE *cmdf = popen(module->command, "r");
	if (!cmdf){
		return;
    }
    char tmpstr[1024] = "";
	char * s;
    int e;
    do {
        errno = 0;
        s = fgets(tmpstr, 1024-(strlen(separator)+1), cmdf);
        e = errno;
    } while (!s && e == EINTR);
	pclose(cmdf);
	int i = strlen(module->icon);

    if (s && hideemptymodule)
        strcpy(output, module->icon);
    else if (!hideemptymodule)
        strcpy(output, module->icon);

    strcpy(output+i, tmpstr);

    remove_all(output, '\n');
    i = strlen(output);
    if ((i > 0 && module != &modules[LENGTH(modules) - 1])){
        strcat(output, separator);
    }
    i+=strlen(separator);
    output[i++] = '\0';
}

static void
syncwrite(void) {
    pthread_mutex_lock(&write_mut);
    writestatus();
    pthread_mutex_unlock(&write_mut);
}

void
threadEvent(union sigval data) {
    Thread_ev *ev = (Thread_ev*) data.sival_ptr;
    getcmd(ev->module, statusbar[ev->idx]);
    syncwrite();
}

void
getcmds(void)
{
	const Module* current;
	for(int i = 0; i < LENGTH(modules); i++)
	{
		current = modules + i;
		getcmd(current,statusbar[i]);
	}
}

#ifndef __OpenBSD__
void
getsigcmds(int signal)
{
	const Module *current;
	for (int i = 0; i < LENGTH(modules); i++)
	{
		current = modules + i;
		if (current->signal == signal){
			getcmd(current,statusbar[i]);
        }
	}
}

void
setupsignals()
{
	for(int i = SIGRTMIN; i <= SIGRTMAX; i++)
		signal(i, SIG_IGN);

	for(int i = 0; i < LENGTH(modules); i++)
	{
		if (modules[i].signal > 0) {
            struct sigaction action;
            sigemptyset(&action.sa_mask);
            action.sa_flags = 0;
            action.sa_handler = sighandler;
            sigaction(SIGRTMIN+modules[i].signal, &action, NULL);
		}
	}
	struct sigaction sigchld_action = {
  		.sa_handler = SIG_DFL,
  		.sa_flags = SA_NOCLDWAIT
	};
	sigaction(SIGCHLD, &sigchld_action, NULL);

}
#endif

int
getstatus(char *str, char *last)
{
	strcpy(last, str);
	str[0] = '\0';
   	if (leftpadding[0] != '\0')
		strcat(str, leftpadding);
    for(int i = 0; i < LENGTH(modules); i++) {
		strcat(str, statusbar[i]);
        if (i == LENGTH(modules) - 1)
            strcat(str, " ");
    }
	str[strlen(str)-1] = '\0';
   	if (rightpadding[0] != '\0')
		strcat(str, rightpadding);
	return strcmp(str, last);
}

void setroot()
{
	if (!getstatus(statusstr[0], statusstr[1]))
		return;
	Display *d = XOpenDisplay(NULL);
	if (d) {
		dpy = d;
	}
	screen = DefaultScreen(dpy);
	root = RootWindow(dpy, screen);
	XStoreName(dpy, root, statusstr[0]);
	XCloseDisplay(dpy);
}

void pstdout()
{
	if (!getstatus(statusstr[0], statusstr[1]))
		return;
    printf("%s\n",statusstr[0]);
	fflush(stdout);
}


void statusloop()
{
#ifndef __OpenBSD__
	setupsignals();
#endif
	setupsignals();
	getcmds();

    sigset_t moduleed;
    sigemptyset(&moduleed);

    timer_t timer_ids[LENGTH(modules)];
    Thread_ev evs[LENGTH(modules)];

    size_t timer_size = 0;
    size_t ev_size = 0;

    for(size_t i = 0; i < LENGTH(modules); i++) {
        const Module *current = modules + i;
        if(current->signal > 0) {
            sigaddset(&moduleed, current->signal);
        }
    }

    sigprocmask(SIG_BLOCK, &moduleed, NULL);

    for(size_t i = 0; i < LENGTH(modules); i++) {
        const Module *current = modules + i;

        timer_t t_id;
        Thread_ev ev;

        timer_ids[timer_size] = t_id;
        evs[ev_size] = ev;


        struct sigevent event;

        if(current->signal == 0) {
            evs[ev_size].module = current;
            evs[ev_size].idx = i;

            event.sigev_notify = SIGEV_THREAD;
            event.sigev_value.sival_ptr = &evs[ev_size];
            event.sigev_notify_function = threadEvent;
        } else {
            event.sigev_notify = SIGEV_SIGNAL;
            event.sigev_signo = current->signal + SIGRTMIN;
        }

        if(timer_create(CLOCK_REALTIME, &event, &timer_ids[timer_size]) == -1)
            err(1, "Failed to create timer");


        struct itimerspec inter;

        inter.it_value.tv_sec = 1;
        inter.it_value.tv_nsec = 0;

        inter.it_interval.tv_sec = current->interval;
        inter.it_interval.tv_nsec = 0;

        if(timer_settime(timer_ids[timer_size], 0, &inter, NULL) == -1) {
            err(1, "Failed to set timer");
        }

        timer_size++;
        ev_size++;
    }

    sigprocmask(SIG_UNBLOCK, &moduleed, NULL);

    while(statusContinue) {
        syncwrite();
        pause();
    }

    for(size_t idx = 0; idx < timer_size; idx++) {
        timer_delete(timer_ids[idx]);
    }
}

#ifndef __OpenBSD__
void sighandler(int signum)
{
	getsigcmds(signum-SIGRTMIN);
    syncwrite();
}

#endif

void termhandler(int signum)
{
	statusContinue = 0;
	exit(0);
}

int main(int argc, char** argv)
{
	for(int i = 0; i < argc; i++)
	{
		if (!strcmp("-d",argv[i]))
			separator = argv[++i];
		else if(!strcmp("-p",argv[i]))
			writestatus = pstdout;
	}
	signal(SIGTERM, termhandler);
	signal(SIGINT, termhandler);
	statusloop();
}
