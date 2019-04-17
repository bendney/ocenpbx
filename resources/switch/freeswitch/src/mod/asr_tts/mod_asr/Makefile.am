include $(top_srcdir)/build/modmake.rulesam
MODNAME=mod_asr

ASR_DIR=/usr

mod_LTLIBRARIES = mod_asr.la
mod_asr_la_SOURCES  = mod_asr.cpp
mod_opal_la_CXXFLAGS   = $(AM_CXXFLAGS) -I$(ASR_DIR)/include
mod_asr_la_LIBADD   = $(switch_builddir)/libfreeswitch.la
mod_asr_la_LDFLAGS  = -L$(ASR_DIR)/lib/ -lpthread -ldl -lopus -lrealTimeUnity -avoid-version -module -no-undefined -shared


