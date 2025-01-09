CC = gcc
CFLAGS = -Wall -lX11 -lXext -lcrypt -DSHADOW_PWD
LDFLAGS = -lX11 -lXext -lcrypt

xtrlock: xtrlock.c
	$(CC) $(CFLAGS) -o xtrlock xtrlock.c $(LDFLAGS)

clean:
	rm -f xtrlock
