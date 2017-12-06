"Step 0. Load data"

import pandas as pd

import os
from os.path import join


# to fix -- make this dynamic/based on path to current script
os.chdir('C:\\Users\\kwebbink\\Documents\\EMuMedia\\WebProjects\\emustats\\emuStatsPyProj')
# # maybe:  
# dir_path = os.path.dirname(os.path.realpath(__file__))
# os.chdir(dir_path)


def load_collection(name):
    # fname = join("emu%s.csv" % name.lower())
    # data = pd.read_csv(fname, infer_datetime_format=True, encoding='latin1')
    data = pd.read_csv("*.csv", infer_datetime_format=True, encoding='latin1')
    data = data.set_index('irn')
    data['CatCatalogSubset'].astype('str')
    # For each collection, compute the stats 
    return pd.DataFrame(
            { 'Qual' : 100*data[['DarCatalogNumber','DarGlobalUniqueIdentifier','DarScientificName','DarYearCollected','SummaryData','DarCountry','MulMimeType']].count()/len(data.index),
                 'Collection' : name})


"Step 1: get a basic interactive categorical bar chart"

##### (Based on http://bokeh.pydata.org/en/latest/docs/reference/charts.html#bar )
from bokeh.charts import Bar, output_file, show, reset_output
from bokeh.models import HoverTool
from bokeh.layouts import row

lichen = load_collection("Lichens")
bryo = load_collection("Bryophytes")
data = pd.concat([lichen, bryo], axis=0)
data['DwCField'] = data.index
data['Qual2'] = data['Qual'].astype(str)

hover=HoverTool(
          tooltips=[('Field', '@DwCField'), ('Quality', '@height')])
hover2=HoverTool(
          tooltips=[('Field', '@DwCField'), ('Quality', '@height')])

# x-axis labels pulled from the 'Index' column, stacking labels from 'Collection'; may want to invert?
bar3 = Bar(data, values='Qual', label='Collection', stack='DwCField',
           agg='sum', tools = [hover], #legend='top_right', 
           title="Collection Data Quality", legend=(450,100), plot_width=400)
# table-like data results in reconfiguration of the chart with no data manipulation
bar4 = Bar(data, values='Qual', label='Collection', legend=(450,100),  group='DwCField',
           agg='sum', #tools = [hover],
           title='Coll Data Qual 2', plot_width=400, tools = [hover2])

# Alternate hover tooltip -- can't figure out how to get numeric value 'Quality' to show
#hover = bar3.select(dict(type=HoverTool))
#hover.tooltips = [('Field', '@DwCField'),('Quality', '$Qual')]

output_file("stacked_bar3.html")
show(row(bar3, bar4))
#####

reset_output()
