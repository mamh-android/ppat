#include <stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <errno.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/ioctl.h>

#define DUMP_FILE "./registers.dump"

struct regdump_region {
	const char * regname;
	int	     offset ;
	int 	        len ;
};

struct regdump_region_list {
	const char 	*region_name;
	struct regdump_region *region;
	int			size;
	int			phyaddr;
};

static struct regdump_region pmua_dump_region[] = {
//	{"PMUA_CC_CP",			0x000, 4},
//	{"PMUA_CC_AP",			0x004, 4},
//	{"PMUA_DM_CC_CP",		0x008, 4},
//	{"PMUA_DM_CC_AP",		0x00c, 4},
	{"PMUA_FC_TIMER",		0x010, 4},
	{"PMUA_CP_IDLE_CFG",		0x014, 4},
	{"PMUA_AP_IDLE_CFG",		0x018, 4},
	{"PMUA_SQU_CLK_GATE_CTRL",	0x01c, 4},
	{"PMUA_CCIC_CLK_GATE_CTRL",	0x028, 4},
	{"PMUA_FBRC0_CLK_GATE_CTRL",	0x02c, 4},
	{"PMUA_FBRC1_CLK_GATE_CTRL",	0x030, 4},
	{"PMUA_USB_CLK_GATE_CTRL",	0x034, 4},
	{"PMUA_ISP_CLK_RES_CTRL",	0x038, 4},
	{"PMUA_PMU_CLK_GATE_CTRL",	0x040, 4},
	{"PMUA_DSI_CLK_RES_CTRL",	0x044, 4},
	{"PMUA_LCD_DSI_CLK_RES_CTRL",	0x04c, 4},
	{"PMUA_CCIC_CLK_RES_CTRL",	0x050, 4},
	{"PMUA_SDH0_CLK_RES_CTRL",	0x054, 4},
	{"PMUA_SDH1_CLK_RES_CTRL",	0x058, 4},
	{"PMUA_USB_CLK_RES_CTRL",	0x05c, 4},
	{"PMUA_NF_CLK_RES_CTRL",	0x060, 4},
	{"PMUA_DMA_CLK_RES_CTRL",	0x064, 4},
	{"PMUA_AES_CLK_RES_CTRL",	0x068, 4},
	{"PMUA_MCB_CLK_RES_CTRL",	0x06c, 4},
	{"PMUA_CP_IMR",			0x070, 4},
	{"PMUA_CP_IRWC",		0x074, 4},
	{"PMUA_CP_ISR",			0x078, 4},
	{"PMUA_SD_ROT_WAKE_CLR",	0x07c, 4},
	{"PMUA_PWR_STBL_TIMER",		0x084, 4},
	{"PMUA_DEBUG_REG",		0x088, 4},
	{"PMUA_SRAM_PWR_DWN",		0x08c, 4},
	{"PMUA_CORE_STATUS",		0x090, 4},
	{"PMUA_RES_FRM_SLP_CLR",	0x094, 4},
	{"PMUA_AP_IMR",			0x098, 4},
	{"PMUA_AP_IRWC",		0x09c, 4},
	{"PMUA_AP_ISR",			0x0a0, 4},
	{"PMUA_VPU_CLK_RES_CTRL",	0x0a4, 4},
	{"PMUA_DTC_CLK_RES_CTRL",	0x0ac, 4},
	{"PMUA_MC_HW_SLP_TYPE",		0x0b0, 4},
	{"PMUA_MC_SLP_REQ_AP",		0x0b4, 4},
	{"PMUA_MC_SLP_REQ_CP",		0x0b8, 4},
	{"PMUA_MC_SLP_REQ_MSA",		0x0bc, 4},
	{"PMUA_MC_SW_SLP_TYPE",		0x0c0, 4},
	{"PMUA_PLL_SEL_STATUS",		0x0c4, 4},
	{"PMUA_SYNC_MODE_BYPASS",	0x0c8, 4},
	{"PMUA_GPU_3D_CLK_RES_CTRL",	0x0cc, 4},
	{"PMUA_SMC_CLK_RES_CTRL",	0x0d4, 4},
	{"PMUA_PWR_CTRL_REG",		0x0d8, 4},
	{"PMUA_PWR_BLK_TMR_REG",	0x0dc, 4},
	{"PMUA_SDH2_CLK_RES_CTRL",	0x0e0, 4},
	{"PMUA_CA7MP_IDLE_CFG1",	0x0e4, 4},
	{"PMUA_MC_CTRL",		0x0e8, 4},
	{"PMUA_PWR_STATUS_REG",		0x0f0, 4},
	{"PMUA_GPU_2D_CLK_RES_CTRL",	0x0f4, 4},
	{"PMUA_CC2_AP",			0x100, 4},
	{"PMUA_DM_CC2_AP",		0x104, 4},
	{"PMUA_TRACE_CONFIG",		0x108, 4},
	{"PMUA_CA7MP_IDLE_CFG0",	0x120, 4},
	{"PMUA_CA7_CORE0_IDLE_CFG",	0x124, 4},
	{"PMUA_CA7_CORE1_IDLE_CFG",	0x128, 4},
	{"PMUA_CA7_CORE0_WAKEUP",	0x12c, 4},
	{"PMUA_CA7_CORE1_WAKEUP",	0x130, 4},
	{"PMUA_CA7_CORE2_WAKEUP",	0x134, 4},
	{"PMUA_CA7_CORE3_WAKEUP",	0x138, 4},
	{"PMUA_DVC_DEBUG",		0x140, 4},
	{"PMUA_CA7MP_IDLE_CFG2",	0x150, 4},
	{"PMUA_CA7MP_IDLE_CFG3",	0x154, 4},
	{"PMUA_CA7_CORE2_IDLE_CFG",	0x160, 4},
	{"PMUA_CA7_CORE3_IDLE_CFG",	0x164, 4},
	{"PMUA_CA7_PWR_MISC",		0x170, 4},
};


static struct regdump_region pmua_dump_region_1088[] = {
	{"PMUA_IRE_CLK_GATE_CTRL",	0x020, 4},
	{"PMUA_HSI_CLK_RES_CTRL",	0x048, 4},
	{"PMUA_FBRC_CLK",		0x080, 4},
	{"PMUA_VPRO_PWRDWN",		0x0a8, 4},
	{"PMUA_GPU_3D_PWRDWN",		0x0d0, 4},
};


static struct regdump_region pmua_dump_region_1L88[] = {
	{"PMUA_CCIC2_CLK_RES_CTRL",	0x024, 4},
	{"PMUA_LTEDMA_CLK_RES_CTRL",	0x048, 4},
	{"DFC_AP",			0x180, 4},
	{"DFC_CP",			0x184, 4},
	{"DFC_STATUS",			0x188, 4},
	{"DFC_LEVEL0",			0x190, 4},
	{"DFC_LEVEL1",			0x194, 4},
	{"DFC_LEVEL2",			0x198, 4},
	{"DFC_LEVEL3",			0x19c, 4},
	{"DFC_LEVEL4",			0x1a0, 4},
	{"DFC_LEVEL5",			0x1a4, 4},
	{"DFC_LEVEL6",			0x1a8, 4},
	{"DFC_LEVEL7",			0x1ac, 4},
};

static struct regdump_region pmudvc_dump_region[] = {
	{"DVCR",			0x2000,4},
	{"VL01STR",			0x2004,4},
	{"VL12STR",			0x2008,4},
	{"VL23STR",			0x200C,4},
	{"VL34STR",			0x2010,4},
	{"VL45STR",			0x2014,4},
	{"VL56STR",			0x201C,4},
	{"VL67STR",			0x2018,4},
	{"DVC_AP",			0x2020,4},
	{"DVC_CP",			0x2024,4},
	{"DVC_DP",			0x2028,4},
	{"DVC_APSUB",			0x202C,4},
	{"DVC_CHIP",			0x2030,4},
	{"DVC_STATUS",			0x2040,4},
	{"DVC_IMR",			0x2050,4},
	{"DVC_ISR",			0x2054,4},
	{"DVC_DEBUG",			0x2058,4},
	{"DVC_EXTRA_STR",		0x205C,4},
};

static struct regdump_region apbs_dump_region[] = {
	{"PLL1_SW_CTRL",		0x100,4},
	{"PLL2_SW_CTRL",		0x104,4},
	{"PLL3_SW_CTRL",		0x108,4},
	{"PLL2_PI_CTRL",		0x118,4},
	{"PLL2_SSC_CTRL",		0x11C,4},
	{"PLL2_FREQOFFSET_CTRL",	0x120,4},
	{"PLL3_PI_CTRL",		0x124,4},
	{"PLL3_SSC_CTRL",		0x128,4},
	{"PLL3_FREQOFFSET_CTRL",	0x12C,4},
};

static struct regdump_region ciu_dump_region[] = {
	{"MC_CONF",			0x40,4},
};

static struct regdump_region pmum_dump_region [] = {
	{"FCCR",			0x08,4},	
	{"CRCR",			0x18,4},
	{"PLL3CR",			0x1C,4},
	{"PLL2CR",			0x34,4},
};

struct regdump_region_list region_list[] = {
	{"pmua_dump_1",pmua_dump_region,     sizeof(pmua_dump_region)     /sizeof(struct regdump_region),0xD4282800},
	{"pmua_dump_2",pmua_dump_region_1088,sizeof(pmua_dump_region_1088)/sizeof(struct regdump_region),0xD4282800},
	{"pmua_dump_3",pmua_dump_region_1L88,sizeof(pmua_dump_region_1L88)/sizeof(struct regdump_region),0xD4282800},
	{"pmudvc_dump",pmudvc_dump_region,   sizeof(pmudvc_dump_region)   /sizeof(struct regdump_region),0xD4050000},
	{"apbs_dump"  ,apbs_dump_region,     sizeof(apbs_dump_region)     /sizeof(struct regdump_region),0xD4090000},
	{"ciu_dump"   ,ciu_dump_region,      sizeof(ciu_dump_region)      /sizeof(struct regdump_region),0xD4282C00},
	{"pmum_dump"  ,pmum_dump_region,     sizeof(pmum_dump_region)     /sizeof(struct regdump_region),0xD4050000},

};
////////////////////////////////////////////////////////////////////////
#define DIE(cond,fmt,vargs ...) \
do{\
		if((cond)){ \
			printf("[asserted @ %s.%d]"fmt,__FILE__,__LINE__,vargs);\
			exit(-1);\
		}\
}while(0) 
////////////////////////////////////////////////////////////////////////
//some helpers for freq change
int reg_ops(unsigned int addr,unsigned int *pval,unsigned int ops)
{
	static int fid = -1;
	static int pagesize, len, len_aligned;

	unsigned int addr_aligned;
	volatile unsigned int *pa;
	void *vpa;

	#define HWMAP_DEVICE "/dev/hwmap"
	#define PAGE_OFFS_BITS(pgsz) ((unsigned long)(pgsz)-1)
	#define PAGE_MASK_BITS(pgsz) (~PAGE_OFFS_BITS(pgsz)) 
	#define REG_READ 1
	#define REG_WRITE 0

	if(fid < 0) {
		len = pagesize = sysconf(_SC_PAGESIZE); 
		fid = open(HWMAP_DEVICE, O_RDWR);
		if(fid < 0){
			system("hw.sh");
			fid = open(HWMAP_DEVICE, O_RDWR); 
		}

		DIE(fid < 0,"cannot open hwmap device %s\n",HWMAP_DEVICE);
	}
	
	addr_aligned = addr & PAGE_MASK_BITS(pagesize);
	len_aligned=((addr + len - addr_aligned) + pagesize - 1) & PAGE_MASK_BITS(pagesize);

	vpa = mmap(0, len_aligned, PROT_READ|PROT_WRITE, MAP_SHARED, fid, addr_aligned);
	DIE(vpa == MAP_FAILED, "mmap failed:%d %s\n",errno,strerror(errno));


rw_ops:
	pa = (volatile unsigned int*)vpa;
	pa += (addr & PAGE_OFFS_BITS(pagesize)) >> 2;

	if(ops == REG_READ) *pval = *pa;
	else		    *pa = *pval;

	//printf("vpa=0x%lx, pa=0x%lx,data=0x%lx\n",vpa,pa,data);
	//printf("addr_aligned=0x%lx,addr=0x%lx\n",addr_aligned,addr);

	//clean up resources
	munmap(vpa,len_aligned);
	//close(fid);
	
	return 0;

}
void  __raw_writel(unsigned int val, unsigned int addr)
{
	reg_ops((unsigned int)addr,&val,0);
}
unsigned int  __raw_readl(unsigned int addr)
{
	unsigned int val = 0xDEADBEEF;
	reg_ops((unsigned int)addr,&val,1);
	return val;
}

//////////////////////////////////////////////////////////////////
int main(int argc, char **argv)
{
	printf("start to dump registers ...\n");
	
	FILE * fp = fopen(DUMP_FILE,"w");
	DIE(fp == NULL,"cannot open dump file:%s\n",DUMP_FILE);

	int id = 0;
	int reg_id = 0;
	for(id = 0;id < sizeof(region_list)/sizeof(struct regdump_region_list);++id) {
		for(reg_id = 0; reg_id < region_list[id].size;++reg_id) {
			int phyaddr = region_list[id].region[reg_id].offset + region_list[id].phyaddr; 
			fprintf(fp,"%s\t%X\t%X\n",region_list[id].region[reg_id].regname,
						 phyaddr,
					    __raw_readl(phyaddr)
			       );	
		}		
	}
	fclose(fp);
	printf("registers dump done, saved to file %s!\n",DUMP_FILE);	
}
//////////////////////////////////////////////////////////////
//end of regdump.c
//////////////////////////////////////////////////////////////
