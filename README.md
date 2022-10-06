# Laboratório de uso do Nagios Core

O objetivo desse laboratório é configurar um ambiente para gerenciamento de dispositivos utilizando o software Nagios.

![Nagios](/images/arquitetura-nagios.png)

Escopo:

* Instalação e configuração do software Nagios Core em uma máquina virtual Linux

  - ref: https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/quickstart.html
  - source:
    - nagioscore: https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
    - plugins: https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
  

* Instalação do software NSCA (aka Nagios agent) em máquinas Linux que serão gerenciadas pelo Nagios Core via porta TCP 5693.

  - ref: https://assets.nagios.com/downloads/nagioscore/docs/Installing_NSCA.pdf
  - source: https://assets.nagios.com/downloads/ncpa/ncpa-latest.el7.x86_64.rpm

* Instalação do software NSClient (aka Nagios agent) em máquinas Windows que serão gerenciadas pelo Nagios Core via port TCP 12489.

  - ref: https://docs.nsclient.org/installing/
  - source: https://nsclient.org/download/0.4.4/

* Instalação do SNMP Service em dispositivos gerenciados.

  - Linux: https://www.site24x7.com/help/admin/adding-a-monitor/configuring-snmp-linux.html
  - Windows: https://www.site24x7.com/help/admin/adding-a-monitor/configuring-snmp-windows.html

* Configuração do Nagios Core adicionando as máquinas para serem gerenciadas via NCPA (Linux), NSClient (Windows), SNMP (Network devices) e ICMP (Todas via ping).


* Referências

  - Nagios Core documentation: https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/4/en/
  - Threshold and Ranges: http://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT

  
