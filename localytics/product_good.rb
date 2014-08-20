#####################################################################################################
# See the two tab delimited files attached:

# products.tab = A list of product names tab delimited with categories
# sales.tab = A list of product names tab delimited with sales amount

# From this data we'd like you to answer two questions:
# What are the top 5 categories by sales
# What is the top product by sales in category 'Candy'

# This comes from when I worked at a company that made back office software for restaurants.  
# You can imagine the second file is a Point of Sale record for the day.
#####################################################################################################
require 'pry'

class Product 
  attr_accessor :name, :category, :sales_amount
  @@categories=[]

  def initialize(name, category=nil, sales_amount=nil)
    @name = name
    @category = category
    @sales_amount = sales_amount
  end

  def self.get_products_and_categories(prod_file)
    products={}
    File.readlines(prod_file).each do |line|
      name = line.split("\t")[0].strip.downcase
      category = line.split("\t")[1]
      
      if category.nil?
        category = "nocategory"  
      else  
        category = category.chomp.downcase
      end

      @@categories << category if !@@categories.include?(category)
      products[name] = Product.new(name,category,0) if !products[name]
    end

    return products
  end  

  def self.get_sales_amounts(products, sales_file)
    File.readlines(sales_file).each do |line|
      name = line.split("\t")[0].strip.downcase
      line.split("\t")[1].nil? ? amount=0 : amount = line.split("\t")[1].strip.to_f 

      if products[name]
        products[name].sales_amount += amount
      else  
        products[name] = Product.new(name,"nocategory",amount)
      end  
    end  
    return products
  end

  def self.top_categories_by_sale(products, top=nil)
    category_hash={}
    @@categories.each do |category|
      category_hash[category] = 0
      products.each do |key,product|
        category_hash[category] += product.sales_amount if product.category == category 
      end
    end
  
    sorted_categories = category_hash.sort_by {|k,value| value }.reverse
    sorted_categories = sorted_categories.take(top) if !top.nil?

    return sorted_categories.to_h
  end  

  def self.top_product_by_sale_in_category(products, category)
    products_in_cat = products.select { |key, product| product.category == category }
    top_product = products_in_cat.sort_by { |k, product| product.sales_amount }.reverse.take(1).to_h 
    
    return top_product
  end

  def self.get_categories
    return @@categories
  end

end

products = Product.get_products_and_categories("products.tab")
products = Product.get_sales_amounts(products, "sales.tab")

puts "\nCATEGORY LIST:\n#{ Product.get_categories.join(", ") }\n "


puts "\nTop 5 Categories:"
categories = Product.top_categories_by_sale(products,5)
categories.each { |name,amount| puts "\t#{name.upcase}: $#{amount.round(2)}" }


puts "\nTop Product By Sale In Category 'candy':"
top_product = Product.top_product_by_sale_in_category(products, "candy")
name = top_product.values[0].name.split.map(&:capitalize).join(' ')
amount = top_product.values[0].sales_amount.round(2)
puts "\tPRODUCT: #{name}\n\tSALES AMOUNT: $#{amount}\n"
