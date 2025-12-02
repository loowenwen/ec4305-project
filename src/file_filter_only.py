import csv

def read_csv(csvfilename):
    """
    Reads a csv file and returns a list of lists
    containing rows in the csv file and its entries.
    """
    with open(csvfilename, encoding='utf-8-sig') as csvfile:
        return list(csv.reader(csvfile))

def index_filter(category_col_index, desire, filename):
    working_data = read_csv(filename)
    filtered_list = []
    for transac in working_data[1:]:
        if transac[category_col_index] == desire:
            filtered_list.append(transac)
        else:
            pass
    return filtered_list

completed_list = index_filter(1, "3 ROOM", "workingfile_prices.csv")

with open('filtered_data_3room.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(completed_list)

