default: t_nvram_prog

VFLAGS = -I. -D_IVERILOG_SIM

t_nvram_prog: t_nvram_prog.v nvram_prog.v
	iverilog $(VFLAGS) -o $@ $^
clean:
	rm t_nvram_prog
