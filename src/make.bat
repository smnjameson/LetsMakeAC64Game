java -cp c:\C64\Tools\KickAssembler\kickass-cruncher-plugins-2.0.jar;c:\C64\Tools\KickAssembler\KickAss.jar cml.kickass.KickAssembler start.asm -vicesymbols -showmem -odir ./bin

C:\C64\Tools\Vice\x64.exe -logfile ./bin/vicelog.txt -moncommands ./bin/start.vs ./bin/start.prg

rem Z:\C64\Tools\u64remote.exe 192.168.8.64 run ./bin/start.prg