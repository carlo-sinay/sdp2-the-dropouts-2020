#! /usr/bin/env python3

###Libraries
import random

import datetime

###Functions
#Padding Zeros
def itas(num,padding):
	output = "00"
	#For 2 chars
	if (padding == 2):
		if (num < 10):
			output = "0" +  str(num)
		else:
			output = str(num)
	#For 3 chars
	if (padding == 3):
		if (num < 10):
			output = "00" +  str(num)
		elif ((num >= 10) and (num < 100)):
			output = "0" + str(num)
		else:
			output = str(num)
	#For 4 chars
	if (padding == 4):
		if (num < 10):
			output = "000" +  str(num)
		elif ((num >= 10) and (num < 100)):
			output = "00" + str(num)
		elif ((num >= 100) and (num < 1000)):
			output = "0" + str(num)
		else:
			output = str(num)
	return output

#Random Date
def random_date(start,end):
	diff = end - start
	int_diff = diff.days
	#Random Day to "add" onto start date
	rand_day = random.randrange(int_diff)

	#Return Random Date
	return start + datetime.timedelta(days=rand_day)

###Main
def main():
	#Open File
	file = open("../data/logs/testLog","w")
	#Open item list file
	item_list_file = open("../data/itemList","r")

	#get number of available items from item list
	items_total = 0
	while(True):
		if(item_list_file.readline() == ""):
			break
		print("Found item!", items_total)
		items_total += 1
	item_list_file.close()
	print(items_total)

	#Start and End Dates
	start = datetime.date(2020,8,15)
	end = datetime.date(2020,10,15)

	output = "String Initialised"
	#Add 1000 Transactions
	usr_in = -1

	#Define Num of Transactions
	while ((usr_in < 1) or (usr_in > 999)):
		try:
			usr_in = int(input("\nMax number of transactions? (1 - 999)\n>"))
		except:
			print("Invalid Input!")
	t_max = usr_in

	usr_in = -1
	#Define Max Item Count
	while ((usr_in < 1) or (usr_in > 99)):
		try:
			usr_in = int(input("\nMax number of items? (1 - 99)\n>"))
		except:
			print("Invalid Input!")
	i_max = usr_in

	transactions = 1
	while (transactions <= t_max):
		#Set random item count for Transaction
		item_count = random.randint(1,i_max)
		#Set Random Date
		t_date = random_date(start,end)
		#Add x number of Items to Transaction
		items = 1
		while (items <= item_count):
			code = random.randint(0,items_total-1) #Up to 5 item types
			qty = random.randint(1,99) #Max Quantity of 99
			price = random.randint(1,9999) #Max Price of 9999


			#Record to Write to File
			output = itas(transactions,3) + "," #Transaction ID
			output += itas(items,3) + "," #Item ID
			output += itas(code,3) + "," #Item Code
			output += itas(qty,2) + "," #Qty
			output += itas(price,4) + "," #Price
			output += t_date.isoformat() + "\n"

			#Write Record
			file.write(output)

			items += 1

		#Next Transaction
		transactions += 1

	#Close File
	file.close()

###Running
print("Generating Populated Log...\n")
main()
print("...Done")
