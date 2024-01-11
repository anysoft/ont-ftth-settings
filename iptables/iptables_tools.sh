#!/bin/sh


# define path to store unauth ip lists
ip_list_file=/etc/anysoft/unauth_ip_lists
frp_log_path=/etc/anysoft/apps/frp/frps.*log
v2ray_log_path=/etc/anysoft/apps/v2ray/*.log
                                                                                                                                                                                       
# check and create file                                                                                                                                                                
if [ ! -f "$ip_list_file" ]; then                                                                                                                                                      
    touch "$ip_list_file"                                                                                                                                                              
fi                                                                                                                                                                                     
                                                                                                                                                                                       
# get ip range by ip. 192.168.1.1 --> 192.168.0.1-192.168.0.255                                                                                                                        
get_ip_ranges(){                                                                                                                                                                       
    ip_range=`curl -sSl http://ip.bczs.net/$1 |grep -oE "IP数据：([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" | awk -F "：" '{print $2}'`                              
}                                                                                                                                                                                      
                                                                                                                                                                                       
# get ip's internat 192.168.1.1 --> 192.168.0.0/16                                                                                                                                     
get_ip_internat(){                                                                                                                                                                     
    IP_ADDRESS=$1                                                                                                                                                                      
    IP_PREFIX="${IP_ADDRESS%.*.*}"                                                                                                                                                     
    TMP_IP_INTERNAT="${IP_PREFIX}.0.0/16"                                                                                                                                              
}                                                                                                                                                                                      
                                                                                                                                                                                       
# get/update local unauth list                                                                                                                                                         
get_unauth_list(){                                                                                                                                                                     
    # scan_frp_log                                                                                                                                                                     
    unauth_frp_ips=$(cat ${frp_log_path} | grep "token in login " -B1 | grep ip | awk '{print $10}' | cut -d':' -f1 | cut -d'[' -f2 | sort -u)                                         
    # scan_v2ray_log                                                                                                                                                                   
    unauth_v2ray_ips=$(cat ${v2ray_log_path} |grep  rejected|grep "invalid user"|awk '{print $3}'|cut -d':' -f1|sort -u)                                                               
    # you can add you own service's unauth ips                                                                                                                                         
    # ....                                                                                                                                                                             
                                                                                                                                                                                       
    # local                                                                                                                                                                            
    unauth_list_local=$(cat ${ip_list_file}|sort -u)                                                                                                                                   

    unauth_list="${unauth_frp_ips} ${unauth_v2ray_ips} ${unauth_list_local}"                                                                                                           
    echo ${unauth_list} | tr ' ' '\n' | sort -u > ${ip_list_file}                                                                                                                      
}                                                                                                                                                                                      
                                                                                                                                                                                       
# Define a function to check and delete an iptables rule                                                                                                                               
insert_iptables_rule() {                                                                                                                                                               
    BIN=$1                                                                                                                                                                             
    TABLE="$2"                                                                                                                                                                         
    RULE="$3"                                                                                                                                                                          
    COUNT=$($BIN-save | fgrep -c -e "$RULE")                                                                                                                                           
    if [ "$COUNT" -gt 0 ]; then                                                                                                                                                        
        echo ""exist in $BIN rule: $RULE"   "                                                                                                                                           
    else                                                                                                                                                                               
        $BIN -t $TABLE -I $RULE                                                                                                                                                        
        echo "add $BIN rule : $RULE"                                                                                                                                                   
    fi                                                                                                                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
# Define a function to check and add an iptables rule                                                                                                                                  
add_iptables_rule() {                                                                                                                                                                  
    BIN=$1                                                                                                                                                                             
    TABLE="$2"                                                                                                                                                                         
    RULE="$3"                                                                                                                                                                          
    COUNT=$($BIN-save | fgrep -c -e "$RULE")                                                                                                                                           
    if [ "$COUNT" -gt 0 ]; then                                                                                                                                                        
        echo "exist in $BIN rule: $RULE"                                                                                                                                           
    else                                                                                                                                                                               
        $BIN -t $TABLE -A $RULE                                                                                                                                                        
        echo "add $BIN rule : $RULE"                                                                                                                                                   
    fi                                                                                                                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
# Define a function to check and delete an iptables rule                                                                                                                               
delete_iptables_rule() {                                                                                                                                                               
    BIN=$1                                                                                                                                                                             
    TABLE="$2"                                                                                                                                                                         
    RULE="$3"                                                                                                                                                                          
    COUNT=$($BIN-save | fgrep -c -e "$RULE")                                                                                                                                           
    if [ "$COUNT" -gt 0 ]; then                                                                                                                                                        
        for i in $(seq 1 $COUNT); do                                                                                                                                                   
            $BIN -t $TABLE -D $RULE                                                                                                                                                    
            echo "Deleted $BIN rule: $RULE"                                                                                                                                        
        done                                                                                                                                                                           
    else                                                                                                                                                                               
        echo "$BIN rule does not exist: $RULE"                                                                                                                                         
    fi                                                                                                                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
                                                                                                                                                                                       
add_wan_whitelist() {                                                                                                                                                                  
    tmp_white_ip=$1                                                                                                                                                                    
    add_iptables_rule "iptables" "filter" "INPUT_ACL_WHITELIST -s ${tmp_white_ip} -i ppp+ -p tcp -j ACCEPT"                                                                            
    add_iptables_rule "iptables" "filter" "INPUT_ACL_WHITELIST -s ${tmp_white_ip} -i wan+ -p tcp -j ACCEPT"                                                                            
}                                                                                                                                                                                      
                                                                                                                                                                                       
delete_wan_whitelist() {                                                                                                                                                               
    tmp_white_ip=$1                                                                                                                                                                    
    delete_iptables_rule "iptables" "filter" "INPUT_ACL_WHITELIST -s ${tmp_white_ip} -i ppp+ -p tcp -j ACCEPT"                                                                         
    delete_iptables_rule "iptables" "filter" "INPUT_ACL_WHITELIST -s ${tmp_white_ip} -i wan+ -p tcp -j ACCEPT"                                                                         
}                                                                                                                                                                                      
                                                                                                                                                                                       
add_input_ip_port() {                                                                                                                                                                  
    if [[ $# -eq 2 ]]; then                                                                                                                                                            
        tmp_input_ip=$1                                                                                                                                                                
        tmp_input_port=$2                                                                                                                                                              
        if echo "$tmp_input_ip" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                    
            tmp_input_ip=${tmp_input_ip}/32                                                                                                                                            
        fi                                                                                                                                                                             
        add_iptables_rule "iptables" "filter" "INPUT_ACL -s ${tmp_input_ip} -p tcp -m tcp --dport ${tmp_input_port} -j ACCEPT"                                                         
        elif [[ $# -eq 1 ]]; then                                                                                                                                                      
        tmp_input=$1                                                                                                                                                                   
        if echo "$tmp_input" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                       
            tmp_input=${tmp_input}/32                                                                                                                                                  
        fi                                                                                                                                                                             
        if echo "$tmp_input" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$'; then                                                                                                
            add_iptables_rule "iptables" "filter" "INPUT_ACL -s ${tmp_input} -j ACCEPT"                                                                                                
        else                                                                                                                                                                           
            add_iptables_rule "iptables" "filter" "INPUT_ACL -p tcp -m tcp --dport ${tmp_input} -j ACCEPT"                                                                             
            add_iptables_rule "ip6tables" "filter" "INPUT_ACL -p tcp -m tcp --dport ${tmp_input} -j ACCEPT"                                                                            
        fi                                                                                                                                                                             
    else                                                                                                                                                                               
        echo "Invalid number of arguments."                                                                                                                                            
    fi                                                                                                                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
delete_input_ip_port() {                                                                                                                                                               
    if [[ $# -eq 2 ]]; then                                                                                                                                                            
        tmp_input_ip=$1                                                                                                                                                                
        tmp_input_port=$2                                                                                                                                                              
        if echo "$tmp_input_ip" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                    
            tmp_input_ip=${tmp_input_ip}/32                                                                                                                                            
        fi                                                                                                                                                                             
        delete_iptables_rule "iptables" "filter" "INPUT_ACL -s ${tmp_input_ip} -p tcp -m tcp --dport ${tmp_input_port} -j ACCEPT"                                                      
        elif [[ $# -eq 1 ]]; then                                                                                                                                                      
        tmp_input=$1                                                                                                                                                                   
        if echo "$tmp_input" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                       
            tmp_input=${tmp_input}/32                                                                                                                                                  
        fi                                                                                                                                                                             
        if echo "$tmp_input" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$'; then                                                                                                
            delete_iptables_rule "iptables" "filter" "INPUT_ACL -s ${tmp_input} -j ACCEPT"                                                                                             
        else                                                                                                                                                                           
            delete_iptables_rule "iptables" "filter" "INPUT_ACL -p tcp -m tcp --dport ${tmp_input} -j ACCEPT"                                                                          
        fi                                                                                                                                                                             
    else                                                                                                                                                                               
        echo "Invalid number of arguments."                                                                                                                                            
    fi                                                                                                                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
                                                                                                                                                                                       
                                                                                                                                                                                       
# add drop rule to INPUT_DMZIF                                                                                                                                                         
add_block_iprange(){                                                                                                                                                                   
    tmp_ip_range=$1                                                                                                                                                                    
    add_iptables_rule "iptables" "filter" "INPUT_DMZIF -m iprange --src-range ${tmp_ip_range} -j DROP"                                                                                 
}                                                                                                                                                                                      
                                                                                                                                                                                       
delete_block_iprange(){                                                                                                                                                                
    tmp_ip_range=$1                                                                                                                                                                    
    delete_iptables_rule "iptables" "filter" "INPUT_DMZIF -m iprange --src-range ${tmp_ip_range} -j DROP"                                                                              
}                                                                                                                                                                                      
                                                                                                                                                                                       
# add drop rule to INPUT_DMZIF                                                                                                                                                         
add_block_ips(){                                                                                                                                                                       
    TMP_IP_INTERNAT=$1                                                                                                                                                                 
    if echo "$TMP_IP_INTERNAT" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                     
        TMP_IP_INTERNAT=${TMP_IP_INTERNAT}/32                                                                                                                                          
    fi                                                                                                                                                                                 
    add_iptables_rule "iptables" "filter" "INPUT_DMZIF -s ${TMP_IP_INTERNAT} -j DROP"                                                                                                  
}                                                                                                                                                                                      
                                                                                                                                                                                       
delete_block_ips(){                                                                                                                                                                    
    TMP_IP_INTERNAT=$1                                                                                                                                                                 
    if echo "$TMP_IP_INTERNAT" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then                                                                                                     
        TMP_IP_INTERNAT=${TMP_IP_INTERNAT}/32                                                                                                                                          
    fi                                                                                                                                                                                 
    delete_iptables_rule "iptables" "filter" "INPUT_DMZIF -s ${TMP_IP_INTERNAT} -j DROP"                                                                                               
}                                                                                                                                                                                      
                                                                                                                                                                                       
                                                                                                                                                                                       
                                                                                                                                                                                       
############################################################################################################################################################                           
block_ip_list_iprange(){                                                                                                                                                               
    while IFS= read -r line; do                                                                                                                                                        
        get_ip_ranges ${line}                                                                                                                                                          
        # echo "${line}"                                                                                                                                                               
        # echo "${ip_range}"                                                                                                                                                           
        add_block_iprange ${ip_range}                                                                                                                                                  
    done < ${ip_list_file}                                                                                                                                                             
}                                                                                                                                                                                      
                                                                                                                                                                                       
                                                                                                                                                                                       
# add drop rule to INPUT_DMZIF                                                                                                                                                         
block_ip_list_internat(){                                                                                                                                                              
    while IFS= read -r line; do                                                                                                                                                        
        get_ip_internat ${line}                                                                                                                                                        
        # echo "${line}"                                                                                                                                                               
        # echo "${TMP_IP_INTERNAT}"                                                                                                                                                    
        # -A INPUT_DMZIF -s 183.136.0.0/16 -j DROP                                                                                                                                     
        add_block_ips  ${TMP_IP_INTERNAT}                                                                                                                                              
    done < ${ip_list_file}                                                                                                                                                             
}                                                                                                                                                                                      
                                                                                                                                                                                       
                                                                                                                                                                                       
main(){                                                                                                                                                                                
    # ###################################### #                                                                                                                                         
    # get_unauth_list                        #                                                                                                                                         
    # add_block_internat                     #                                                                                                                                         
    #                                        #                                                                                                                                         
    #                                        #                                                                                                                                         
    #                                        #                                                                                                                                         
    #                                        #                                                                                                                                         
    # ###################################### #                                                                                                                                         

    # update unath list                                                                                                                                                                
    get_unauth_list                                                                                                                                                                    

    # add unauth list's internat into iptables INPUT_DMZIF                                                                                                                             
    block_ip_list_internat                                                                                                                                                             


    # add iptables access accept                                                                                                                                                       
    # add_iptables_rule "iptables" "filter" "INPUT_ACL -s 1.1.1.1 --dport 5244 -j ACCEPT"                                                                                         


    # deny access   INPUT_DMZIF INPUT_ACL  INPUT_ACL_WHITELIST                                                                                                                         
    # iptables -A INPUT_DMZIF -p tcp -m iprange --src-range 183.11.0.0-183.17.255.255 --dport 55244 -j DROP                                                                            
    # iptables -A INPUT_DMZIF -p tcp -m tcp -s 1.1.1.1 --dport 55244 -j DROP                                                                                                      
    # iptables -A INPUT_DMZIF -s 1.1.1.1 -j DROP                                                                                                                                

    # add_iptables_rule "iptables" "filter" "INPUT_DMZIF -p tcp -m tcp -s 1.1.1.1 --dport 55244 -j DROP"                                                                          

    # add ip6tables firewall drop all ppp+    
    add_iptables_rule "ip6tables" "filter" "FWD_FIREWALL -i ppp+ -j DROP"                                                                                                                                          
    add_iptables_rule "ip6tables" "filter" "FWD_FIREWALL -i wan+ -j DROP"     
                                                                                                                                         
    add_iptables_rule "ip6tables" "filter" "FWD_FIREWALL -i ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT"                                                                                                                                          
    add_iptables_rule "ip6tables" "filter" "FWD_FIREWALL -i wan+ -m state --state RELATED,ESTABLISHED -j ACCEPT"  


    # insert_iptables_rule "ip6tables" "filter" "FORWARD 1 -i ppp+ -o br+ -p tcp --dport 8006 -j ACCEPT"                                                                                                                                          
    # insert_iptables_rule "ip6tables" "filter" "FORWARD 1 -i ppp+ -o br+ -p tcp --dport 8006 -j ACCEPT"                                                                                                                                          
                                                                                                                                                                                       

    # ### add white list  INPUT_ACL_WHITELIST                                                                                                                                          
    add_wan_whitelist 1.1.1.1/32                                                                                                                                                  
                                                                                                                                                                                       
    # ### open service                                                                                                                                                                 
    # v2ray                                                                                                                                                                            
    add_input_ip_port 11080                                                                                                                                                            
    # alist                                                                                                                                                                            
    add_input_ip_port 55244                                                                                                                                                            
    # v2ray sg                                                                                                                                                                         
    add_input_ip_port 60808                                                                                                                                                            
    # frps                                                                                                                                                                             
    add_input_ip_port 7000:7001                                                                                                                                                        
                                                                                                                                                                                       
    # ### delete                                                                                                                                                                       
    # delete dns proxy tcp                                                                                                                                                             
    delete_iptables_rule "iptables" "nat" "PRE_DNS_REDIRECT_LOCAL ! -d 192.168.1.0/24 -i br+ -p tcp -m tcp --dport 53 -j DNAT --to-destination 192.168.1.1:53"                         
    # delet dns proxy udp                                                                                                                                                              
    delete_iptables_rule "iptables" "nat" "PRE_DNS_REDIRECT_LOCAL ! -d 192.168.1.0/24 -i br+ -p udp -m udp --dport 53 -j DNAT --to-destination 192.168.1.1:53"                         
                                                                                                                                                                                       
    # delte web redirect                                                                                                                                                               
    delete_iptables_rule "iptables" "nat" "PRE_REDIRECT -d 192.168.1.1/32 -i br+ -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.1.1:8080"                                   
    delete_iptables_rule "iptables" "nat" "PRE_REDIRECT -d 192.168.1.1/32 -i br+ -p tcp -m tcp --dport 80 -j DNAT --to-destination 192.168.1.1:8080"                                   
                                                                                                                                                                                       
    # delte web redirect ipv6                                                                                                                                                          
    delete_iptables_rule "ip6tables" "nat" "PREROUTING -i br0 -p tcp -m tcp --dport 80 -j DNAT --to-destination [fe80::1]:8080"                                                        
    delete_iptables_rule "ip6tables" "nat" "PREROUTING -i br0 -p tcp -m tcp --dport 80 -j DNAT --to-destination [fe80::1]:8080"                                                        
                                                                                                                                                                                       
}                                                                                                                                                                                      
                                                                                                                                                                                       
usage(){                                                                                                                                                                               
    script_name=$(basename "$0")                                                                                                                                                       

    echo "Invalid method: $method"                                                                                                                                                     
    echo "./${script_name} add_wan_whitelist or delete_wan_whitelist"                                                                                                                  
    echo "params/usage:"                                                                                                                                                               
    echo "     192.168.1.1/32"                                                                                                                                                         
    echo " "                                                                                                                                                                           
    echo "./${script_name} add_input_ip_port or delete_input_ip_port"                                                                                                                  
    echo "params/usage:"                                                                                                                                                               
    echo "     192.168.1.1/32"                                                                                                                                                         
    echo "     192.168.1.1/32 80"                                                                                                                                                      
    echo "     80"                                                                                                                                                                     
    echo ""                                                                                                                                                                            
    echo " "                                                                                                                                                                           
    echo "./${script_name} delete_block_iprange or delete_block_iprange"                                                                                                               
    echo "params/usage:"                                                                                                                                                               
    echo "     192.168.1.1-192.168.1.255"                                                                                                                                              
    echo " "                                                                                                                                                                           
    echo "./${script_name} add_block_ips or delete_block_ips"                                                                                                                          
    echo "params/usage:"                                                                                                                                                               
    echo "     192.168.1.1/32"                                                                                                                                                         
}                                                                                                                                                                                      
                                                                                                                                                                                       
if [[ $# -lt 1 ]]; then                                                                                                                                                                
    echo "no arguments run main function"                                                                                                                                              
    main                                                                                                                                                                               
    elif [[ $# -gt 1 ]]; then                                                                                                                                                          
    method=$1                                                                                                                                                                          
    shift 1                                                                                                                                                                            
    param="$@"                                                                                                                                                                         
    case $method in                                                                                                                                                                    
        "add_wan_whitelist")                                                                                                                                                           
            add_wan_whitelist $param                                                                                                                                                   
        ;;                                                                                                                                                                             
        "delete_wan_whitelist")                                                                                                                                                        
            delete_wan_whitelist $param                                                                                                                                                
        ;;                                                                                                                                                                             
        "add_input_ip_port")                                                                                                                                                           
            add_input_ip_port $param                                                                                                                                                   
        ;;                                                                                                                                                                             
        "delete_input_ip_port")                                                                                                                                                        
            delete_input_ip_port $param                                                                                                                                                
        ;;                                                                                                                                                                             
        "add_block_iprange")                                                                                                                                                           
            add_block_iprange $param                                                                                                                                                   
        ;;                                                                                                                                                                             
        "delete_block_iprange")                                                                                                                                                        
            delete_block_iprange $param                                                                                                                                                
        ;;                                                                                                                                                                             
        "add_block_ips")                                                                                                                                                               
            add_block_ips $param                                                                                                                                                       
        ;;                                                                                                                                                                             
        "delete_block_ips")                                                                                                                                                            
            delete_block_ips $param                                                                                                                                                    
        ;;                                                                                                                                                                             
        "add_iptables_rule")                                                                                                                                                            
            add_iptables_rule $param                                                                                                                                                    
        ;;                                                                                                                                                                             
        "insert_iptables_rule")                                                                                                                                                            
            insert_iptables_rule $param                                                                                                                                                    
        ;;                                                                                                                                                                             
        *)                                                                                                                                                                             
            usage                                                                                                                                                                      
        ;;                                                                                                                                                                             
    esac                                                                                                                                                                               
else                                                                                                                                                                                   
    usage                                                                                                                                                                              
fi                                                                                                                                                                                     
                                                        