import csv

def read_csv(csvfilename):
    """
    Reads a csv file and returns a list of lists
    containing rows in the csv file and its entries.
    """
    with open(csvfilename, encoding='utf-8-sig') as csvfile:
        return list(csv.reader(csvfile))

class OutputError(Exception):
    def _init_(self, value):
        self.value = value
    def _str_(self):
        return repr(self.value)

# parse inflation data

inflation_data = read_csv("inflation.csv")
dct_inf = dict()
for month_inf_pair in inflation_data:
    month = month_inf_pair[0]
    inf = month_inf_pair[1]
    dct_inf.update({month: inf})

# add inflation data to resale prices

resale_prices = read_csv("filtered_agg_data_3room.csv")

for transac in resale_prices:
    month_transac = transac[0]
    useful_data = []
    if month_transac in dct_inf.keys():
        inf_rate = dct_inf[month_transac]
        transac.append(inf_rate)
    else:
        raise OutputError("No value found")

with open('full_agg_data.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(resale_prices)
