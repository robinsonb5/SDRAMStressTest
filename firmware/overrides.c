#include "menu.h"
#include "interrupts.h"
#include "ps2.h"

extern unsigned char menupage;
extern int menuindex;

void buildmenu(int offset);

int main(int argc,char **argv)
{
	int havesd;
	int i,c;
	int osd=0;
	char *err;

	PS2Init();

	menuindex=0;
	menupage=0;

	buildmenu(0);

	EnableInterrupts();

	while(1)
	{
		Menu_Run();
	}

	return(0);
}

