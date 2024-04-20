// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/*import "@openzeppelin/contracts/access/Ownable.sol";*/
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract APSale is AccessControl {
    bytes32 public constant WHITE_LIST_ROLE = keccak256(abi.encodePacked("WHITE_LIST_ROLE"));

    IERC20 public apToken;
    /*
    @dev
    apToken adında satılacak tokenin adresini, her satış türü için fiyat,
    minimum ve maksimum satın alma miktarları,
    ve satış başlangıç ve bitiş zamanları gibi parametrelerle oluşturulur.
    @dev
    */
    uint256 public pricePrivatesale;
    uint256 public pricePublicsale;
    uint256 public minimumBuyPrivatesale;
    uint256 public maximumBuyPrivatesale;
    uint256 public startTimePrivatesale;
    uint256 public endTimePrivatesale;
    uint256 public startTimePublicsale;
    uint256 public endTimePublicsale;
    uint256 public raisedAmount;
    mapping(address => uint256) public boughtAmount; // Her adresin satın aldığı token miktarı

    constructor(
        address _apToken,
        uint256 _pricePrivatesale,
        uint256 _pricePublicsale,
        uint256 _minimumBuyPrivatesale,
        uint256 _maximumBuyPrivatesale,
        uint256 _startTimePrivatesale,
        uint256 _endTimePrivatesale,
        uint256 _startTimePublicsale,
        uint256 _endTimePublicsale
    ) {
        apToken = IERC20(_apToken);
        pricePrivatesale = _pricePrivatesale;
        pricePublicsale = _pricePublicsale;
        minimumBuyPrivatesale = _minimumBuyPrivatesale;
        maximumBuyPrivatesale = _maximumBuyPrivatesale;
        startTimePrivatesale = _startTimePrivatesale;
        endTimePrivatesale = _endTimePrivatesale;
        startTimePublicsale = _startTimePublicsale;
        endTimePublicsale = _endTimePublicsale;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        /*
        @param
        Kontratın sahibi, DEFAULT_ADMIN_ROLE rolüne atanır.
        Bu rol, whitelist'e kullanıcı ekleme ve çıkarma gibi
        yönetimsel işlemleri gerçekleştirme yetkisi verir.
        @param
        */
    }

    function addToWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        /*
        @param
        addToWhitelist fonksiyonu, bir kullanıcıyı whitelist'e eklemek için kullanılır.
        Bu fonksiyon sadece DEFAULT_ADMIN_ROLE rolüne sahip kullanıcılar tarafından çağrılabilir.
        @param
        */
        grantRole(WHITE_LIST_ROLE, account);
    }

    function removeFromWhitelist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(WHITE_LIST_ROLE, account);

        /*
        @param
        removeFromWhitelist fonksiyonu, bir kullanıcıyı whitelist'ten çıkarmak için kullanılır.
        Bu fonksiyon sadece DEFAULT_ADMIN_ROLE rolüne sahip kullanıcılar tarafından çağrılabilir.
        @param
        */
    }

    // Satın alma işlemini güvenli hale getirmek için SafeERC20
    function buyPrivatesale(uint256 amount) public {
        /*
        @Privatesale:

Bir kullanıcı, buyPrivatesale fonksiyonunu çağırarak token satın almak ister.
Kontrat, kullanıcının adresinin whitelist'te olup olmadığını kontrol eder.
Kullanıcı whitelist'te değilse, işlem başarısız olur.
Kullanıcı whitelist'te ise, kontrat satın alma miktarının minimum ve maksimum sınırlamalara uygun olup olmadığını kontrol eder.
Satın alma miktarı sınırlamalara uyuyorsa, kontrat kullanıcının ödediği ETH miktarını alır.
Kontrat, kullanıcının satın aldığı token miktarını hesaplar.
Kontrat, satın alınan tokenleri kullanıcının cüzdanına güvenli bir şekilde aktarır.
Kontrat, toplanan ETH miktarını ve satılan token miktarını günceller.
TokenPurchased olayı tetiklenir.

        */
        require(hasRole(WHITE_LIST_ROLE, msg.sender), "Address is not whitelisted");
        require(block.timestamp >= startTimePrivatesale && block.timestamp <= endTimePrivatesale, "Privatesale is not active");
        require(amount >= minimumBuyPrivatesale, "Minimum buy amount not met");
        require(boughtAmount[msg.sender] + amount <= maximumBuyPrivatesale, "Maximum buy amount exceeded");

        uint256 ethAmount = amount * pricePrivatesale;
        require(msg.value >= ethAmount, "Insufficient ETH sent");

        uint256 remainingAmount = amount - boughtAmount[msg.sender];
        boughtAmount[msg.sender] += remainingAmount;

        uint256 tokensToTransfer = remainingAmount * 10**apToken.decimals();
        SafeERC20.transferFrom(apToken, address(this), msg.sender, tokensToTransfer);

        raisedAmount += ethAmount;
        emit TokenPurchased(msg.sender, amount, pricePrivatesale);
        /*
        @param
        TokenPurchased olayı, bir token satın alma işlemi gerçekleştiğinde tetiklenir.
        Bu olay, satın alınan token miktarı, fiyat ve alıcının adresini içeren bilgileri içerir.
        @param
        */
    }

    function buyPublicsale(uint256 amount) public {
    /*
    @Publicsale:

Bir kullanıcı, buyPublicsale fonksiyonunu çağırarak token satın almak ister.
Kontrat, satın alma miktarının minimum sınırı aşıyorsa, kontrat kullanıcının ödediği ETH miktarını alır.
Kontrat, kullanıcının satın aldığı token miktarını hesaplar.
Kontrat, satın alınan tokenleri kullanıcının cüzdanına güvenli bir şekilde aktarır.
Kontrat, toplanan ETH miktarını ve satılan token miktarını günceller.
TokenPurchased olayı tetiklenir.

    */
        require(block.timestamp >= startTimePublicsale && block.timestamp <= endTimePublicsale, "Publicsale is not active");
        require(amount >= minimumBuyPrivatesale, "Minimum buy amount not met");

        uint256 ethAmount = amount * pricePublicsale;
        require(msg.value >= ethAmount, "Insufficient ETH sent");

        uint256 tokensToTransfer = amount * 10**apToken.decimals();
        SafeERC20.transferFrom(apToken, address(this), msg.sender
