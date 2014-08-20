#!/usr/bin/python
import operator

class Product(object):
  def __init__(self, name, category, amount):
    self.name = name
    self.category = category
    self.sales_amount = amount
  
categories=[]

def get_products_and_categories(product_file):
  products={}

  file_object = open(product_file, "r")
  for line in file_object:
    name = line.split("\t")[0].strip().lower()

    if len(line.split("\t")) < 2:
      category ="nocategory"
    else:        
      category = line.split("\t")[1].strip().lower()
    
    if category not in categories:
      categories.append(category)
    if name not in products: 
      products[name]={}
    products[name] = Product(name,category,0).__dict__ 

  file_object.close()

  return products
    
def get_sales_amounts(products, sales_file):
  file_object = open(sales_file,"r")
  for line in file_object:
    name = line.split("\t")[0].strip().lower()
     
    if len(line.split("\t")) < 2:
      amount=0
    else:
      amount = float(line.split("\t")[1].strip())

    if name in products:
      products[name]['sales_amount'] += amount
    else:
      products[name] = Product(name,'nocategory',amount).__dict__
  
  file_object.close()

  return products
  
def top_categories_by_sale(products,top):
  cat_amounts =[]

  for category in categories:
    total=0
    for i in products:
      if products[i]['category'] == category:
        total += products[i]['sales_amount']

    cat_amounts.append((category,total))

  sorted_categories = sorted(cat_amounts, key=operator.itemgetter(1))
  sorted_categories.reverse()

  return sorted_categories[:top]

def top_product_in_category(products,category):
  all_prods = products_in_category(products,category)
  top_product = sorted(all_prods, key=operator.itemgetter(1)) 
  top_product.reverse()
  
  return top_product[:1]
      

def products_in_category(products,category):
  cat_amounts =[]
  total=0
  for i in products:
    if products[i]['category'] == category:
      cat_amounts.append((products[i]['name'],products[i]['sales_amount']))
  return cat_amounts   


# ------------------------------------
products = get_products_and_categories('products.tab')
products = get_sales_amounts(products, 'sales.tab')

print "---------------------------------------\n"
print "\nTo 5 categories by sale:"
for cat in top_categories_by_sale(products,5):
  print "\t" + cat[0].upper() + ": " + "$" + str(cat[1])
print "---------------------------------------\n"

print "Top product in category 'candy':"
top_product = top_product_in_category(products,'candy')[0]
print "\t" + top_product[0].title() + ": " + "$" + str(top_product[1])
print "---------------------------------------\n"
