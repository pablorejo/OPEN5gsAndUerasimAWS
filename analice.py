import json
from pathlib import Path
import statistics
 


def analiza_json(path_json, protocolo):
    data = json.loads(path_json.read_text())
    if protocolo == 'tcp':
        if len(data['end']) > 0:
            streams = data['end']['streams'][0]
            
            sender = streams['sender']
            receiver = streams['receiver']
            
            bps_sender  = sender['bits_per_second']
            bps_receiver  = receiver['bits_per_second']
            bps_compare = (bps_receiver/bps_sender)*100
            max_rtt = sender['max_rtt']/1000
            min_rtt = sender['min_rtt']/1000
            mean_rtt = sender['mean_rtt']/1000
            retransmits  = sender['retransmits']
            
            return bps_sender, bps_receiver, bps_compare, max_rtt, min_rtt, mean_rtt, retransmits, None, None
        
        else:
            return None, None, None, None, None, None, None, None, None
    else:  # 'udp'
        
        if len(data['end']) > 0:
            streams = data['end']['streams'][0]['udp']
            
            bps      = streams['bits_per_second']
            jitter   = streams['jitter_ms'] 
            lost_pct = streams['lost_percent']
            
            
            # para latencia UDP habría que usar otro test ICMP
            return bps, None, None, None, None, None, None, jitter, lost_pct
        else:
            return None, None, None, None, None, None, None, None, None

base  = Path('files','logs')

resultados = []

for fjson in base.glob('*.json'):
    
    # puerto, rate = fjson.name.replace('.json','').replace('port','').split('_',maxsplit=2)
    
    
    bps_sender, bps_receiver, bps_compare, max_rtt, min_rtt, mean_rtt, retransmits, jitter, lost_pct = analiza_json(fjson, 'tcp')
    resultados.append({
        'slice': fjson.name,
        # 'puerto': puerto,
        'protocolo':'tcp',
        # 'rate': rate,
        'bps_sender': round((bps_sender),2) if bps_sender != None else  None,
        'bps_receiver': round(bps_receiver,2) if bps_receiver != None else  None,
        'bps_compare': round(bps_compare,2) if bps_compare != None else  None,
        'max_rtt (ms)': round(max_rtt,2) if max_rtt != None else  None,
        'min_rtt (ms)': round(min_rtt,2) if min_rtt != None else  None,
        'mean_rtt (ms)': round(mean_rtt,2) if mean_rtt != None else  None,
        'retransmits': round(retransmits,2) if retransmits != None else  None,
        'jitter (ms)': round(jitter,2) if jitter != None else  None,
        'lost_pct': round(lost_pct,2)  if lost_pct != None else  None
    })
# conviertes resultados a DataFrame y comparas con tus umbrales:
import pandas as pd
df = pd.DataFrame(resultados)
df.to_csv('data.csv',index=False)
print(df)
