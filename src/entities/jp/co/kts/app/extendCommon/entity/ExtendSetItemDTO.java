package jp.co.kts.app.extendCommon.entity;

import jp.co.kts.app.common.entity.SetItemDTO;

public class ExtendSetItemDTO extends SetItemDTO {

	/** 品番 */
	private String itemCode;

	/** 商品名 */
	private String itemNm;

	/** 出庫分類フラグ */
	private String leaveClassFlg;

	/** 仕様メモ */
	private String specMemo;
	/**
	 * @return itemCode
	 */
	public String getItemCode() {
		return itemCode;
	}

	/**
	 * @param itemCode セットする itemCode
	 */
	public void setItemCode(String itemCode) {
		this.itemCode = itemCode;
	}

	/**
	 * @return itemNm
	 */
	public String getItemNm() {
		return itemNm;
	}

	/**
	 * @param itemNm セットする itemNm
	 */
	public void setItemNm(String itemNm) {
		this.itemNm = itemNm;
	}

	/**
	 * @return leaveClassFlg
	 */
	public String getLeaveClassFlg() {
		return leaveClassFlg;
	}

	/**
	 * @param leaveClassFlg セットする leaveClassFlg
	 */
	public void setLeaveClassFlg(String leaveClassFlg) {
		this.leaveClassFlg = leaveClassFlg;
	}

	/**
	 * @return specMemo
	 */
	public String getSpecMemo() {
		return specMemo;
	}

	/**
	 * @param specMemo セットする specMemo
	 */
	public void setSpecMemo(String specMemo) {
		this.specMemo = specMemo;
	}

}
