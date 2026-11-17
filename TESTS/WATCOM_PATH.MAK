# Checks WMAKE's actual macro evaluation, not the CMD environment variable.
!ifndef WATCOM
!error NBJWLINK: missing WATCOM make macro
!endif
probe: .SYMBOLIC
	@echo WATCOM_MACRO_RESOLVED=$(WATCOM)
