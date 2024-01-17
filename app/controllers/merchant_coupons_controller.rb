class MerchantCouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
    @coupons = @merchant.coupons
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = @merchant.coupons.where(id: params[:id]).first
  end

  def new 
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    if merchant.five_active_coupons?
      flash[:notice] = 'You have reached max coupon limit of 5.'
      redirect_to merchant_coupons_path(merchant)
    elsif !merchant.unique_coupon_code?(params[:code])
      flash[:notice] = 'Coupon code already exists'
      redirect_to new_merchant_coupon_path(merchant)
    else 
      merchant.coupons.create!(coupon_params)
      redirect_to merchant_coupons_path(merchant)
    end
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    if merchant.invoices.in_progress.count >= 1 
      flash[:alert] = 'Cannot deactivate coupons with pending invoices.'
      redirect_to merchant_coupon_path(merchant, coupon)
    else 
      # Toggle the status: if it's 'active', make it 'inactive'; if it's 'inactive', make it 'active'
      new_status = (coupon.status == 'active') ? 'inactive' : 'active'
      
      coupon.update!(status: new_status)
      redirect_to merchant_coupon_path(merchant, coupon)
    end
  end

  private 

  def coupon_params
    params.permit(:name, :code, :discount, :status)
  end
end