module CartsHelper
	def remove_from_cart(id)
		RecordList.find(id).destroy
	end
end
