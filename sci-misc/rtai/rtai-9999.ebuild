EAPI="3"

PYTHON_DEPEND="2"

inherit linux-mod python cvs flag-o-matic

DESCRIPTION="Real Time Application Interface for Linux"
HOMEPAGE="https://www.rtai.org/"
ECVS_SERVER="cvs.gna.org:/cvs/rtai"
ECVS_MODULE="magma"
ECVS_BRANCH="HEAD"
ECVS_AUTH="pserver"
ECVS_USERNAME="anonymous"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug +fpu +testsuite doc compat +static-inline extern-inline +diag-tsc-sync +master-tsc-cpu +tune-tsc-sync sched-lock-isr +rtc-freq long-timed-lists +sched-8254-latency +sched-apic-latency +sched-lxrt-numslots +lxrt-use-linux-syscall  align-priority +cal-freq-fact +bits +fifos +netrpc netrpc-rtnet +shm +sem rt-poll rt-poll-on-stack +msg +mbx +tbx +tasklets +mq +math math-c99 +malloc malloc-tlsf +malloc-vmalloc +malloc-heap-size +kstack-heap-size task-switch-signal trace +usi +watchdog leds comedi-lxrt comedi-lock cplusplus +rtdm +rtdm-fd-max +rtdm-shirq +rtdm-select +serial +16550a rtailab ktasks-sched-lxrt"

RDEPEND="sys-kernel/rtai-sources
"

DEPEND="${RDEPEND}
"

S="${WORKDIR}/magma"
src_unpack() {
        cvs_src_unpack
}

src_configure () {
        econf \
                --with-module-dir="/lib/modules/${KV_FULL}/rtai" \
                --enable-cpus=3 \
                --prefix="/usr/realtime" \
                $(use_enable fpu) \
                $(use_enable testsuite) \
                $(use_enable doc dox-doc) \
                $(use_enable doc latex-doc) \
                $(use_enable doc verbose-latex) \
                $(use_enable doc dbx) \
                $(use_enable compat) \
                $(use static-inline && echo --with-lxrt-inline=static) \
                $(use extern-inline && echo --with-lxrt-inline=extern) \
                $(use_enable diag-tsc-sync) \
                $(use_enable master-tsc-cpu master-tsc-cpu 0) \
                $(use_enable tune-tsc-sync) \
                $(use_enable sched-lock-isr) \
                $(use_enable rtc-freq rtc-freq 0) \
                $(use_enable long-timed-lists) \
                $(use_enable sched-8254-latency sched-8254-latency 4700) \
                $(use_enable sched-apic-latency sched-apic-latency 3944) \
                $(use_enable sched-lxrt-numslots sched-lxrt-numslots 150) \
                $(use_enable lxrt-use-linux-syscall) \
                $(use_enable align-priority) \
                $(use_enable cal-freq-fact cal-freq-fact 0) \
                $(use_enable bits bits m) \
                $(use_enable fifos fifos m) \
                $(use_enable netrpc netrpc m) \
                $(use_enable netrpc-rtnet netrpc-rtnet m) \
                $(use_enable shm shm m) \
                $(use_enable sem sem m) \
                $(use_enable rt-poll rt-poll m) \
                $(use_enable rt-poll-on-stack rt-poll-on-stack m) \
                $(use_enable msg msg m) \
                $(use_enable mbx mbx m) \
                $(use_enable tbx tbx m) \
                $(use_enable tasklets tasklets m) \
                $(use_enable mq mq m) \
                $(use_enable math math m) \
                $(use_enable math-c99 math-c99 m) \
                $(use_enable malloc) \
                $(use_enable malloc-tlsf) \
                $(use_enable malloc-vmalloc) \
                $(use_enable malloc-heap-size malloc-heap-size 2048) \
                $(use_enable kstack-heap-size kstack-heap-size 512) \
                $(use_enable task-switch-signal) \
                $(use_enable trace) \
                $(use_enable usi usi m) \
                $(use_enable watchdog watchdog m) \
                $(use_enable leds leds m) \
                $(use_enable comedi-lxrt comedi-lxrt m) \
                $(use_enable comedi-lock comde-lock m) \
                $(use_enable cplusplus cplusplus m) \
                $(use_enable rtdm) \
                $(use_enable rtdm-fd-max rtdm-fd-max 128) \
                $(use_enable rtdm-shirq) \
                $(use_enable rtdm-select) \
                $(use_enable debug enable-debug-rtdm) \
                $(use_enable serial) \
                $(use_enable 16550a) \
                $(use 16550a && echo --with-16550a-ham=any) \
                $(use_enable rtailab) \
                $(use_enable debug module-debug) \
                $(use_enable debug user-debug) \
                $(use_enable ktasks-sched-lxrt)
        # remove invalid file delete
        find . -name 'GNUmakefile' -type f -print0 | xargs -0 sed -i 's:rm -f /usr/src/linux/.tmp_versions/rtai_\*.mod /usr/src/linux/.tmp_versions/\*_rt.mod;::g'
}

src_install () {
        emake  DESTDIR="${D}" install || die "install failed"
        rm "${D}/usr/realtime/include/asm"
        mv "${D}/usr/realtime/include/asm-i386" "${D}/usr/realtime/include/asm" || die "rename failed"
        dodoc README.* ChangeLog || die
}