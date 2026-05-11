-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 05, 2026 at 04:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `aneuso_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bids`
--

CREATE TABLE `bids` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `waste_category_id` bigint(20) NOT NULL,
  `quantity_kg` decimal(10,2) NOT NULL,
  `price_per_kg` decimal(10,2) NOT NULL,
  `total_value` decimal(12,2) NOT NULL,
  `bid_type_id` bigint(20) NOT NULL,
  `bid_status_id` bigint(20) NOT NULL,
  `validity_start` date NOT NULL,
  `validity_end` date NOT NULL,
  `special_conditions` text DEFAULT NULL,
  `location_address` text NOT NULL,
  `preferred_pickup_time` varchar(191) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `blocked_industries`
--

CREATE TABLE `blocked_industries` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `blocked_by_user_id` bigint(20) NOT NULL,
  `reason` text NOT NULL,
  `evidence_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`evidence_urls`)),
  `permanent_block` tinyint(1) DEFAULT 1,
  `blocked_at` datetime DEFAULT current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `branches`
--

CREATE TABLE `branches` (
  `id` bigint(20) NOT NULL,
  `branch_name` varchar(191) NOT NULL,
  `branch_code` varchar(191) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `contact_phone_number` varchar(191) NOT NULL,
  `contact_email` varchar(191) NOT NULL,
  `branch_address` text NOT NULL,
  `is_main_branch` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `branches`
--

INSERT INTO `branches` (`id`, `branch_name`, `branch_code`, `company_id`, `contact_phone_number`, `contact_email`, `branch_address`, `is_main_branch`, `created_at`, `updated_at`) VALUES
(9, 'MetalRecovery - Foundry 2', 'MET-001', 8, '+1-555-010-1004', 'sales@metrecovery.com', '321 Metal Drive, Industrial Park, IP 10004', 1, '2026-01-15 13:27:13', '2026-01-24 13:03:25'),
(10, 'PaperReclaim - Mill A', 'PAP-001', 9, '+1-555-010-1005', 'info@paperreclaim.com', '654 Pulp Street, Paper City, PC 10005', 1, '2026-01-15 13:27:13', '2026-01-24 13:03:35'),
(11, 'GlassRenew - West Facility', 'GLA-001', 10, '+1-555-010-1006', 'contact@glassrenew.com', '987 Crystal Avenue, Glassville, GL 10006', 1, '2026-01-15 13:27:13', '2026-01-24 13:03:43'),
(13, 'OrganicFert - Farm Depot', 'ORG-001', 12, '+1-555-010-1008', 'sales@organicfert.com', '258 Fertilizer Road, Agro Town, AT 10008', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(14, 'PlastiCycle - Polymer Plant', 'PLA-001', 13, '+1-555-010-1009', 'info@plasticycle.com', '369 Polymer Street, Plastic City, PL 10009', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(19, 'ConstructionRecycle - C&D Site', 'CON-001', 18, '+1-555-010-1014', 'info@conrecycle.com', '753 Builders Street, Construct City, CN 10014', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(20, 'TextileRecovery - Fabric Processing', 'TEX-001', 19, '+1-555-010-1015', 'contact@textilerec.com', '456 Fabric Lane, Textile Town, TX 10015', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(21, 'Compost Masters - Yard 2', 'COM-001', 20, '+1-555-010-1016', 'support@compostmasters.com', '852 Soil Street, Garden City, GC 10016', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(22, 'Aluminum Recycle - Smelter Site', 'ALU-001', 21, '+1-555-010-1017', 'sales@alrecycle.com', '963 Light Metal Drive, Aluminum City, AL 10017', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(23, 'BioChar Solutions - Production Site', 'BIOC-001', 22, '+1-555-010-1018', 'info@biocharsol.com', '741 Carbon Road, Bio City, BC 10018', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(24, 'WastePower Energy - Incinerator', 'PWR-001', 23, '+1-555-010-1019', 'power@wasteenergy.com', '159 Energy Drive, Power City, PW 10019', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(25, 'EcoConcrete - Aggregate Mixer', 'ECC-001', 24, '+1-555-010-1020', 'contact@ecoconcrete.com', '357 Aggregate Street, Build City, BL 10020', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(26, 'PlasticLumber - Molding Facility', 'PLU-001', 25, '+1-555-010-1021', 'sales@plasticlumber.com', '852 Synthetic Road, Plastic Park, PP 10021', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(27, 'GlassWorks Designs - Studio', 'GLW-001', 26, '+1-555-010-1022', 'info@glassworks.com', '963 Art Glass Avenue, Design City, DC 10022', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(28, 'OrganicPest Control - Laboratory', 'ORGP-001', 27, '+1-555-010-1023', 'contact@organicpest.com', '741 Garden Road, Farm Town, FT 10023', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(29, 'CarpetRecycle - Fiber Separator', 'CAR-001', 28, '+1-555-010-1024', 'sales@carpetrec.com', '159 Flooring Street, Carpet City, CP 10024', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(30, 'SteelRecovery - Heavy Industry', 'STE-001', 29, '+1-555-010-1025', 'info@steelrecovery.com', '357 Iron Drive, Steel Town, ST 10025', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(31, 'EcoPackaging - Production Line', 'ECP-001', 30, '+1-555-010-1026', 'support@ecopack.com', '852 Package Street, Green City, GC 10026', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(32, 'BatteryRecycle - Battery Lab', 'BAT-001', 31, '+1-555-010-1027', 'contact@batteryrec.com', '963 Power Cell Road, Energy Park, EP 10027', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(33, 'CeramicReclaim - Kiln Site', 'CER-001', 32, '+1-555-010-1028', 'sales@ceramicrec.com', '741 Clay Avenue, Pottery City, PC 10028', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(34, 'SoilAmend - Earthworks', 'SOI-001', 33, '+1-555-010-1029', 'info@soilsamend.com', '159 Earth Road, Agriculture Park, AP 10029', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(35, 'PET Fabric - Weaving Mill', 'PET-001', 34, '+1-555-010-1030', 'contact@petfabric.com', '357 Bottle Fiber Street, Textile Park, TP 10030', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(36, 'PaperBoard - Converting Plant', 'PAB-001', 35, '+1-555-010-1031', 'sales@paperboard.com', '852 Cardboard Road, Packaging City, PK 10031', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(37, 'GlassBead Artisans - Workshop', 'GLB-001', 36, '+1-555-010-1032', 'info@glassbeadart.com', '963 Bead Street, Artisan Town, AR 10032', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(38, 'FarmWaste Converters - Field Ops', 'FAR-001', 37, '+1-555-010-1033', 'contact@farmwaste.com', '741 Rural Road, Farm County, FC 10033', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(39, 'PVC Recycle - Extrusion Unit', 'PVC-001', 38, '+1-555-010-1034', 'sales@pvcrecycle.com', '159 Pipe Street, Plastic Valley, PV 10034', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(40, 'RubberProducts - Manufacture', 'RUBP-001', 39, '+1-555-010-1035', 'info@rubberprod.com', '357 Elastic Road, Rubber Park, RP 10035', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(41, 'YardWaste Solutions - Suburb Drop', 'YAR-001', 40, '+1-555-010-1036', 'support@yardwaste.com', '852 Garden Waste Drive, Suburb City, SC 10036', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(42, 'ComponentRecovery - Disassembly', 'COM-002', 41, '+1-555-010-1037', 'contact@comporec.com', '963 Circuit Road, Tech Valley, TV 10037', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(43, 'TileRenew Industries - Showroom', 'TIL-001', 42, '+1-555-010-1038', 'sales@tilerenew.com', '741 Surface Street, Design Park, DP 10038', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(44, 'CompostTea Producers - Brewing', 'COMT-001', 43, '+1-555-010-1039', 'info@composttea.com', '159 Liquid Fertilizer Road, Farm Hub, FH 10039', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(45, 'EcoFurniture Designs - Assembly', 'ECF-001', 44, '+1-555-010-1040', 'contact@ecofurniture.com', '357 Recycled Street, Home Design City, HD 10040', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(46, 'MetalArt Creations - Gallery', 'MET-002', 45, '+1-555-010-1041', 'sales@metalart.com', '852 Sculpture Avenue, Art District, AD 10041', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(47, 'BioPlanters Co - Greenhouse', 'BIOP-001', 46, '+1-555-010-1042', 'info@bioplanters.com', '963 Planter Street, Garden Market, GM 10042', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(48, 'ReGlass Tableware - Glass Blowing', 'REG-001', 47, '+1-555-010-1043', 'contact@reglass.com', '741 Dinnerware Road, Home Goods City, HG 10043', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(49, 'WormFarm Organics - Beds Unit', 'WOR-001', 48, '+1-555-010-1044', 'sales@wormfarm.com', '159 Vermicompost Lane, Organic Valley, OV 10044', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(50, 'EcoBag Manufacturers - Converting', 'ECB-001', 49, '+1-555-010-1045', 'info@ecobag.com', '357 Carry Bag Street, Retail Park, RP 10045', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(51, 'WoodChip Processing - Chipper Site', 'WOC-001', 50, '+1-555-010-1046', 'contact@woodchip.com', '852 Mulch Drive, Forestry Town, FT 10046', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(52, 'GlassAgg Supply - Sand Mixer', 'GLA-002', 51, '+1-555-010-1047', 'sales@glassagg.com', '963 Construction Sand Road, Builders City, BC 10047', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(53, 'CompostExtracts Ltd - Fermentation', 'COME-001', 52, '+1-555-010-1048', 'info@compostext.com', '741 Liquid Extract Avenue, Bio Park, BP 10048', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(54, 'PlastiContain Inc - Storage Depot', 'PLC-001', 1, '+1-555-010-1049', 'contact@plasticontain.com', '159 Container Street, Packaging Park, PP 10049', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(55, 'MetalSheet Co - Rolling Mill', 'METS-001', 3, '+1-555-010-1050', 'sales@metalsheet.com', '357 Flat Metal Road, Manufacturing Zone, MZ 10050', 0, '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(60, 'Main Branch', 'BRCj-001', 12, '03303030303', 'myemail@mail.com', 'Karachi', 1, '2026-01-24 13:11:52', '2026-01-24 13:11:52');

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `session_id` varchar(191) DEFAULT NULL,
  `status_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `session_id`, `status_id`, `created_at`, `updated_at`) VALUES
(1, 71, NULL, 2, '2026-01-21 14:03:35', '2026-01-21 14:56:32'),
(2, 71, NULL, 2, '2026-01-21 14:56:46', '2026-01-21 14:57:58'),
(3, 71, NULL, 1, '2026-01-21 14:58:06', NULL),
(4, 69, NULL, 2, '2026-01-21 17:32:57', '2026-01-22 14:37:17'),
(5, 69, NULL, 2, '2026-01-22 14:37:39', '2026-01-22 14:38:22'),
(6, 69, NULL, 2, '2026-01-22 14:38:43', '2026-01-22 19:32:34'),
(7, 69, NULL, 2, '2026-01-22 19:32:51', '2026-01-22 19:33:15'),
(8, 69, NULL, 2, '2026-01-22 19:33:38', '2026-01-24 10:34:35'),
(9, 69, NULL, 2, '2026-01-24 10:34:40', '2026-01-24 10:36:16'),
(10, 69, NULL, 1, '2026-01-24 10:36:44', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` bigint(20) NOT NULL,
  `cart_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_at_time` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart_items`
--

INSERT INTO `cart_items` (`id`, `cart_id`, `product_id`, `quantity`, `price_at_time`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 2, 150.75, '2026-01-21 14:03:49', '2026-01-21 14:04:10'),
(2, 2, 2, 1, 2.55, '2026-01-21 14:57:20', '2026-01-21 14:57:47'),
(15, 4, 2, 4, 2.55, '2026-01-22 14:36:17', '2026-01-22 14:37:01'),
(16, 5, 2, 4, 2.55, '2026-01-22 14:37:50', '2026-01-22 14:38:02'),
(17, 6, 1, 4, 150.75, '2026-01-22 19:32:02', '2026-01-22 19:32:16'),
(18, 7, 2, 4, 2.55, '2026-01-22 19:32:54', '2026-01-22 19:32:58'),
(19, 8, 2, 2, 2.55, '2026-01-22 19:33:43', '2026-01-22 19:33:45'),
(20, 8, 108, 1, 23.00, '2026-01-24 10:30:05', NULL),
(22, 9, 1, 2, 150.75, '2026-01-24 10:35:03', '2026-01-24 10:35:08'),
(25, 10, 1, 2, 150.75, '2026-01-24 10:42:17', '2026-01-24 10:42:17');

-- --------------------------------------------------------

--
-- Table structure for table `ceo_messages`
--

CREATE TABLE `ceo_messages` (
  `id` bigint(20) NOT NULL,
  `sender_user_id` bigint(20) NOT NULL,
  `recipient_user_id` bigint(20) DEFAULT NULL,
  `recipient_company_id` bigint(20) DEFAULT NULL,
  `recipient_type_id` bigint(20) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `message_type_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `sent_at` datetime DEFAULT current_timestamp(),
  `delivered_at` datetime DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `read_count` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `companies`
--

CREATE TABLE `companies` (
  `id` bigint(20) NOT NULL,
  `company_name` varchar(191) NOT NULL,
  `company_type_id` bigint(20) NOT NULL,
  `business_type_id` bigint(20) NOT NULL,
  `contact_phone_number` varchar(191) NOT NULL,
  `contact_email` varchar(191) NOT NULL,
  `company_address` text NOT NULL,
  `is_headquarter` tinyint(1) DEFAULT 0,
  `waste_type` varchar(191) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `companies`
--

INSERT INTO `companies` (`id`, `company_name`, `company_type_id`, `business_type_id`, `contact_phone_number`, `contact_email`, `company_address`, `is_headquarter`, `waste_type`, `created_at`, `updated_at`) VALUES
(1, 'IBAaaaaaaabbbb', 28, 33, '+923308060604', 'misbahmaqboolofficial@gmail.com', 'Ashiyana Clifton, Karachi', 1, 'Agricultural Waste', '2026-01-15 13:27:13', '2026-01-24 12:54:11'),
(2, 'Misbahs Tech', 32, 34, '+926605050504', 'misbah@gmail.com', 'Karachi Pakistan', 1, 'Electronic Waste (E-Waste)', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(3, 'EcoWaste Solutions Ltd', 27, 35, '+1-555-010-1001', 'info@ecowaste.com', '123 Green Street, Eco City, EC 10001', 1, 'Mixed Waste', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(4, 'GreenCycle Recycling Inc', 28, 36, '+1-555-010-1002', 'contact@greencycle.com', '456 Recycling Road, Greenville, GR 10002', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(5, 'BioConvert Organics', 29, 37, '+1-555-010-1003', 'support@bioconvert.com', '789 Compost Lane, Bio Town, BT 10003', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(6, 'MetalRecovery Corp', 30, 38, '+1-555-010-1004', 'sales@metrecovery.com', '321 Metal Drive, Industrial Park, IP 10004', 0, 'Metal', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(7, 'PaperReclaim Ltd', 31, 39, '+1-555-010-1005', 'info@paperreclaim.com', '654 Pulp Street, Paper City, PC 10005', 0, 'Paper', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(8, 'GlassRenew Industries', 32, 40, '+1-555-010-1006', 'contact@glassrenew.com', '987 Crystal Avenue, Glassville, GL 10006', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(9, 'E-Waste Solutions', 27, 41, '+1-555-010-1007', 'support@ewaste-sol.com', '147 Tech Park, Electronics City, EC 10007', 0, 'Electronic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(10, 'OrganicFert Co', 28, 42, '+1-555-010-1008', 'sales@organicfert.com', '258 Fertilizer Road, Agro Town, AT 10008', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(11, 'PlastiCycle Processing', 29, 43, '+1-555-010-1009', 'info@plasticycle.com', '369 Polymer Street, Plastic City, PL 10009', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(12, 'WoodRevive Ltd', 30, 44, '+1-555-010-1010', 'contact@woodrevive.com', '741 Timber Lane, Woodville, WD 10010', 0, 'Wood', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(13, 'CityWaste Management', 31, 45, '+1-555-010-1011', 'municipal@citywaste.com', '852 Municipal Drive, Capital City, CC 10011', 1, 'Mixed Waste', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(14, 'BioGas Energy Co', 32, 46, '+1-555-010-1012', 'energy@biogas.com', '963 Energy Park, Power Town, PT 10012', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(15, 'RubberReclaim Inc', 27, 47, '+1-555-010-1013', 'sales@rubberreclaim.com', '159 Tire Avenue, Rubber City, RC 10013', 0, 'Rubber', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(16, 'ConstructionRecycle Ltd', 28, 48, '+1-555-010-1014', 'info@conrecycle.com', '753 Builders Street, Construct City, CN 10014', 0, 'Construction', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(17, 'TextileRecovery Corp', 29, 49, '+1-555-010-1015', 'contact@textilerec.com', '456 Fabric Lane, Textile Town, TX 10015', 0, 'Textile', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(18, 'Compost Masters', 30, 50, '+1-555-010-1016', 'support@compostmasters.com', '852 Soil Street, Garden City, GC 10016', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(19, 'Aluminum Recycle Co', 31, 51, '+1-555-010-1017', 'sales@alrecycle.com', '963 Light Metal Drive, Aluminum City, AL 10017', 0, 'Metal', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(20, 'BioChar Solutions', 32, 52, '+1-555-010-1018', 'info@biocharsol.com', '741 Carbon Road, Bio City, BC 10018', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(21, 'WastePower Energy', 27, 53, '+1-555-010-1019', 'power@wasteenergy.com', '159 Energy Drive, Power City, PW 10019', 0, 'Mixed Waste', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(22, 'EcoConcrete Ltd', 28, 54, '+1-555-010-1020', 'contact@ecoconcrete.com', '357 Aggregate Street, Build City, BL 10020', 0, 'Construction', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(23, 'PlasticLumber Inc', 29, 55, '+1-555-010-1021', 'sales@plasticlumber.com', '852 Synthetic Road, Plastic Park, PP 10021', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(24, 'GlassWorks Designs', 30, 56, '+1-555-010-1022', 'info@glassworks.com', '963 Art Glass Avenue, Design City, DC 10022', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(25, 'OrganicPest Control', 31, 57, '+1-555-010-1023', 'contact@organicpest.com', '741 Garden Road, Farm Town, FT 10023', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(26, 'CarpetRecycle Corp', 32, 58, '+1-555-010-1024', 'sales@carpetrec.com', '159 Flooring Street, Carpet City, CP 10024', 0, 'Textile', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(27, 'SteelRecovery Ltd', 27, 59, '+1-555-010-1025', 'info@steelrecovery.com', '357 Iron Drive, Steel Town, ST 10025', 0, 'Metal', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(28, 'EcoPackaging Solutions', 28, 60, '+1-555-010-1026', 'support@ecopack.com', '852 Package Street, Green City, GC 10026', 0, 'Paper', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(29, 'BatteryRecycle Inc', 29, 61, '+1-555-010-1027', 'contact@batteryrec.com', '963 Power Cell Road, Energy Park, EP 10027', 0, 'Electronic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(30, 'CeramicReclaim Co', 30, 62, '+1-555-010-1028', 'sales@ceramicrec.com', '741 Clay Avenue, Pottery City, PC 10028', 0, 'Ceramic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(31, 'SoilAmend Ltd', 31, 63, '+1-555-010-1029', 'info@soilsamend.com', '159 Earth Road, Agriculture Park, AP 10029', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(32, 'PET Fabric Co', 32, 64, '+1-555-010-1030', 'contact@petfabric.com', '357 Bottle Fiber Street, Textile Park, TP 10030', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(33, 'PaperBoard Products', 27, 65, '+1-555-010-1031', 'sales@paperboard.com', '852 Cardboard Road, Packaging City, PK 10031', 0, 'Paper', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(34, 'GlassBead Artisans', 28, 66, '+1-555-010-1032', 'info@glassbeadart.com', '963 Bead Street, Artisan Town, AR 10032', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(35, 'FarmWaste Converters', 29, 67, '+1-555-010-1033', 'contact@farmwaste.com', '741 Rural Road, Farm County, FC 10033', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(36, 'PVC Recycle Inc', 30, 68, '+1-555-010-1034', 'sales@pvcrecycle.com', '159 Pipe Street, Plastic Valley, PV 10034', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(37, 'RubberProducts Ltd', 31, 69, '+1-555-010-1035', 'info@rubberprod.com', '357 Elastic Road, Rubber Park, RP 10035', 0, 'Rubber', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(38, 'YardWaste Solutions', 32, 70, '+1-555-010-1036', 'support@yardwaste.com', '852 Garden Waste Drive, Suburb City, SC 10036', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(39, 'ComponentRecovery Co', 27, 71, '+1-555-010-1037', 'contact@comporec.com', '963 Circuit Road, Tech Valley, TV 10037', 0, 'Electronic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(40, 'TileRenew Industries', 28, 72, '+1-555-010-1038', 'sales@tilerenew.com', '741 Surface Street, Design Park, DP 10038', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(41, 'CompostTea Producers', 29, 73, '+1-555-010-1039', 'info@composttea.com', '159 Liquid Fertilizer Road, Farm Hub, FH 10039', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(42, 'EcoFurniture Designs', 30, 74, '+1-555-010-1040', 'contact@ecofurniture.com', '357 Recycled Street, Home Design City, HD 10040', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(43, 'MetalArt Creations', 31, 75, '+1-555-010-1041', 'sales@metalart.com', '852 Sculpture Avenue, Art District, AD 10041', 0, 'Metal', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(44, 'BioPlanters Co', 32, 76, '+1-555-010-1042', 'info@bioplanters.com', '963 Planter Street, Garden Market, GM 10042', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(45, 'ReGlass Tableware', 27, 77, '+1-555-010-1043', 'contact@reglass.com', '741 Dinnerware Road, Home Goods City, HG 10043', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(46, 'WormFarm Organics', 28, 78, '+1-555-010-1044', 'sales@wormfarm.com', '159 Vermicompost Lane, Organic Valley, OV 10044', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(47, 'EcoBag Manufacturers', 29, 79, '+1-555-010-1045', 'info@ecobag.com', '357 Carry Bag Street, Retail Park, RP 10045', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(48, 'WoodChip Processing', 30, 80, '+1-555-010-1046', 'contact@woodchip.com', '852 Mulch Drive, Forestry Town, FT 10046', 0, 'Wood', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(49, 'GlassAgg Supply', 31, 81, '+1-555-010-1047', 'sales@glassagg.com', '963 Construction Sand Road, Builders City, BC 10047', 0, 'Glass', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(50, 'CompostExtracts Ltd', 32, 82, '+1-555-010-1048', 'info@compostext.com', '741 Liquid Extract Avenue, Bio Park, BP 10048', 0, 'Organic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(51, 'PlastiContain Inc', 27, 83, '+1-555-010-1049', 'contact@plasticontain.com', '159 Container Street, Packaging Park, PP 10049', 0, 'Plastic', '2026-01-15 13:27:13', '2026-01-15 13:27:13'),
(52, 'MetalSheet Co', 28, 84, '+1-555-010-1050', 'sales@metalsheet.com', '357 Flat Metal Road, Manufacturing Zone, MZ 10050', 0, 'Metal', '2026-01-15 13:27:13', '2026-01-15 13:27:13');

-- --------------------------------------------------------

--
-- Table structure for table `company_users`
--

CREATE TABLE `company_users` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `branch_id` bigint(20) NOT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `designations`
--

CREATE TABLE `designations` (
  `id` bigint(20) NOT NULL,
  `designation_name` varchar(191) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `designations`
--

INSERT INTO `designations` (`id`, `designation_name`, `created_at`, `updated_at`) VALUES
(1, 'manager', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(2, 'HR', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(3, 'support', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(4, 'IT', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(5, 'supervisor', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(6, 'coordinator', '2025-11-11 11:33:58', '2025-11-11 11:33:58'),
(7, 'officer', '2025-11-11 11:33:58', '2025-11-11 11:33:58');

-- --------------------------------------------------------

--
-- Table structure for table `drivers`
--

CREATE TABLE `drivers` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `national_id` varchar(191) NOT NULL,
  `vehicle_name` varchar(191) NOT NULL,
  `vehicle_plate_number` varchar(191) NOT NULL,
  `driving_license_number` varchar(191) NOT NULL,
  `driving_experience_in_months` int(11) NOT NULL,
  `approval_status` tinyint(1) DEFAULT 0,
  `approval_reason` varchar(191) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `drivers`
--

INSERT INTO `drivers` (`id`, `user_id`, `national_id`, `vehicle_name`, `vehicle_plate_number`, `driving_license_number`, `driving_experience_in_months`, `approval_status`, `approval_reason`, `created_at`, `updated_at`) VALUES
(4, 24, 'NID000024', 'International LT', 'WTZ024', 'DL00000024', 13, 0, 'Approved after background check', '2025-11-11 11:34:08', '2025-11-11 11:34:08'),
(15, 35, 'NID000035', 'Chevrolet Silverado', 'MNA035', 'DL00000035', 23, 0, 'Pending documentation', '2025-11-11 11:34:08', '2025-11-11 11:34:08'),
(18, 75, 'NID000021', 'Toyota Hilux', 'AWQ980', 'DL000181309', 44, 1, NULL, '2026-01-21 20:47:07', '2026-01-21 20:47:07');

-- --------------------------------------------------------

--
-- Table structure for table `driver_tasks`
--

CREATE TABLE `driver_tasks` (
  `id` bigint(20) NOT NULL,
  `driver_id` bigint(20) NOT NULL,
  `pickup_schedule_id` bigint(20) NOT NULL,
  `task_date` date NOT NULL,
  `task_status_id` bigint(20) NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `route_order` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `email_messages`
--

CREATE TABLE `email_messages` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `email` varchar(191) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `message_type_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `body` text DEFAULT NULL,
  `provider_message_id` varchar(255) DEFAULT NULL,
  `provider_response` text DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  `opened_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `garbage_report_donations`
--

CREATE TABLE `garbage_report_donations` (
  `id` bigint(20) NOT NULL,
  `report_id` bigint(20) NOT NULL,
  `donor_user_id` bigint(20) DEFAULT NULL,
  `donor_name` varchar(191) DEFAULT NULL,
  `donor_email` varchar(191) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `transaction_id` varchar(191) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `status_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `industry_priorities`
--

CREATE TABLE `industry_priorities` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `priority_score` decimal(5,2) NOT NULL,
  `position` int(11) NOT NULL,
  `last_updated_by_user_id` bigint(20) NOT NULL,
  `comments` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `industry_ratings`
--

CREATE TABLE `industry_ratings` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `rated_by_user_id` bigint(20) NOT NULL,
  `waste_separation_rating` int(11) DEFAULT NULL,
  `cooperation_rating` int(11) DEFAULT NULL,
  `facility_rating` int(11) DEFAULT NULL,
  `overall_rating` decimal(3,2) NOT NULL,
  `points_awarded` int(11) NOT NULL,
  `comments` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `industry_rewards`
--

CREATE TABLE `industry_rewards` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `total_points` int(11) NOT NULL DEFAULT 0,
  `available_points` int(11) NOT NULL DEFAULT 0,
  `used_points` int(11) NOT NULL DEFAULT 0,
  `current_tier_id` bigint(20) DEFAULT NULL,
  `benefits_active` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`benefits_active`)),
  `last_calculated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL,
  `sender_user_id` bigint(20) NOT NULL,
  `recipient_user_id` bigint(20) DEFAULT NULL,
  `recipient_type_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `notification_type_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `priority_level_id` bigint(20) DEFAULT 2,
  `scheduled_at` datetime DEFAULT NULL,
  `sent_at` datetime DEFAULT NULL,
  `read_at` datetime DEFAULT NULL,
  `action_url` varchar(500) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `company_id` bigint(20) DEFAULT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `discount_amount` decimal(10,2) DEFAULT 0.00,
  `tax_amount` decimal(10,2) DEFAULT 0.00,
  `final_amount` decimal(12,2) NOT NULL,
  `shipping_address` text NOT NULL,
  `billing_address` text NOT NULL,
  `order_status_id` bigint(20) NOT NULL,
  `payment_status_id` bigint(20) NOT NULL,
  `payment_method_id` bigint(20) DEFAULT NULL,
  `transaction_id` varchar(191) DEFAULT NULL,
  `promotion_id` bigint(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `order_number`, `user_id`, `company_id`, `total_amount`, `discount_amount`, `tax_amount`, `final_amount`, `shipping_address`, `billing_address`, `order_status_id`, `payment_status_id`, `payment_method_id`, `transaction_id`, `promotion_id`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'ORD-D9EC7B74', 71, NULL, 301.50, 0.00, 30.15, 331.65, 'aaaaaa', 'aaaaaa', 1, 1, 156, NULL, NULL, NULL, '2026-01-21 14:56:32', NULL),
(2, 'ORD-01D2AB95', 71, NULL, 2.55, 0.00, 0.26, 2.80, 'sssss', 'sssss', 1, 1, 156, NULL, NULL, NULL, '2026-01-21 14:57:58', NULL),
(3, 'ORD-77351170', 69, NULL, 10.20, 0.00, 1.02, 11.22, 'aaaaa', 'aaaaa', 1, 1, 156, NULL, NULL, 'aaaaa', '2026-01-22 14:37:17', NULL),
(4, 'ORD-9A31F92C', 69, NULL, 10.20, 0.00, 1.02, 11.22, 'aaa', 'aaa', 1, 1, 156, NULL, NULL, 'aaaa', '2026-01-22 14:38:22', NULL),
(5, 'ORD-045948BC', 69, NULL, 603.00, 0.00, 60.30, 663.30, '1111', '1111', 1, 1, 156, NULL, NULL, '11111', '2026-01-22 19:32:34', NULL),
(6, 'ORD-BBED4A69', 69, NULL, 10.20, 0.00, 1.02, 11.22, 'ddd', 'ddd', 1, 1, 156, NULL, NULL, 'dddd', '2026-01-22 19:33:15', NULL),
(7, 'ORD-66B2180A', 69, NULL, 28.10, 0.00, 2.81, 30.91, 'aaaaaaaaaaa', 'aaaaaaaaaaa', 1, 1, 156, NULL, NULL, 'aaaaaaaaaaaaaaaaa', '2026-01-24 10:34:35', NULL),
(8, 'ORD-56539CD4', 69, NULL, 301.50, 0.00, 30.15, 331.65, 'aaaaaaaaaaaaa', 'aaaaaaaaaaaaa', 1, 1, 156, NULL, NULL, 'aaaaaaaaaaaaaaaaaaaaa', '2026-01-24 10:36:16', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `total_price` decimal(12,2) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `unit_price`, `total_price`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 2, 150.75, 301.50, '2026-01-21 14:56:32', NULL),
(2, 2, 2, 1, 2.55, 2.55, '2026-01-21 14:57:58', NULL),
(3, 3, 2, 4, 2.55, 10.20, '2026-01-22 14:37:17', NULL),
(4, 4, 2, 4, 2.55, 10.20, '2026-01-22 14:38:22', NULL),
(5, 5, 1, 4, 150.75, 603.00, '2026-01-22 19:32:34', NULL),
(6, 6, 2, 4, 2.55, 10.20, '2026-01-22 19:33:15', NULL),
(7, 7, 2, 2, 2.55, 5.10, '2026-01-24 10:34:35', NULL),
(8, 7, 108, 1, 23.00, 23.00, '2026-01-24 10:34:35', NULL),
(9, 8, 1, 2, 150.75, 301.50, '2026-01-24 10:36:16', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `otps`
--

CREATE TABLE `otps` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `email` varchar(191) NOT NULL,
  `otp_code` varchar(10) NOT NULL,
  `purpose_id` bigint(20) NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `attempts` tinyint(3) DEFAULT 0,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `otps`
--

INSERT INTO `otps` (`id`, `user_id`, `email`, `otp_code`, `purpose_id`, `status_id`, `attempts`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, NULL, 'misbahmaqbool54@gmail.com', '553399', 5, 11, 0, '2026-01-21 13:57:15', '2026-01-21 13:47:15', NULL),
(2, NULL, 'misbahmaqbool54@gmail.com', '174463', 5, 10, 0, '2026-01-21 13:57:17', '2026-01-21 13:47:17', NULL),
(3, NULL, 'ali@gmail.com', '861534', 5, 10, 0, '2026-01-21 20:57:45', '2026-01-21 20:47:45', NULL),
(4, NULL, 'ali@gmail.com', '631456', 5, 10, 0, '2026-01-21 21:02:59', '2026-01-21 20:52:59', NULL),
(5, NULL, 'ali@gmail.com', '623792', 5, 10, 0, '2026-01-21 21:17:16', '2026-01-21 21:07:16', NULL),
(6, NULL, 'ali@gmail.com', '523624', 5, 10, 0, '2026-01-22 14:58:23', '2026-01-22 14:48:23', NULL),
(7, NULL, 'ali@gmail.com', '545423', 5, 10, 0, '2026-01-22 18:33:28', '2026-01-22 18:23:28', NULL),
(8, NULL, 'ali@gmail.com', '164665', 5, 10, 0, '2026-01-22 20:51:35', '2026-01-22 20:41:35', NULL),
(9, NULL, 'misbahmaqbool54@gmail.com', '546834', 5, 11, 0, '2026-01-23 16:55:30', '2026-01-23 16:45:30', NULL),
(10, NULL, 'ali@gmail.com', '259377', 5, 10, 0, '2026-01-24 10:15:27', '2026-01-24 10:05:27', NULL),
(11, NULL, 'ali@gmail.com', '501443', 5, 10, 0, '2026-04-22 09:54:01', '2026-04-22 09:44:01', NULL),
(12, NULL, 'ali@gmail.com', '841610', 5, 10, 0, '2026-04-22 10:07:26', '2026-04-22 09:57:26', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pickup_confirmations`
--

CREATE TABLE `pickup_confirmations` (
  `id` bigint(20) NOT NULL,
  `pickup_schedule_id` bigint(20) NOT NULL,
  `driver_id` bigint(20) NOT NULL,
  `confirmation_time` datetime NOT NULL,
  `collected_weight_kg` decimal(10,2) NOT NULL,
  `driver_latitude` decimal(10,8) DEFAULT NULL,
  `driver_longitude` decimal(11,8) DEFAULT NULL,
  `verification_status_id` bigint(20) NOT NULL,
  `issue_reported_id` bigint(20) DEFAULT NULL,
  `issue_description` text DEFAULT NULL,
  `photos_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`photos_urls`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pickup_confirmations`
--

INSERT INTO `pickup_confirmations` (`id`, `pickup_schedule_id`, `driver_id`, `confirmation_time`, `collected_weight_kg`, `driver_latitude`, `driver_longitude`, `verification_status_id`, `issue_reported_id`, `issue_description`, `photos_urls`, `created_at`, `updated_at`) VALUES
(5, 8, 18, '2026-01-21 20:53:36', 20.00, 0.00000000, 0.00000000, 1, NULL, NULL, '[]', '2026-01-21 20:53:36', NULL),
(10, 13, 18, '2026-04-22 09:53:45', 200.00, 0.00000000, 0.00000000, 1, 3, NULL, '[]', '2026-04-22 09:53:45', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pickup_schedules`
--

CREATE TABLE `pickup_schedules` (
  `id` bigint(20) NOT NULL,
  `bid_id` bigint(20) DEFAULT NULL,
  `company_id` bigint(20) NOT NULL,
  `branch_id` bigint(20) NOT NULL,
  `driver_id` bigint(20) DEFAULT NULL,
  `scheduled_date` date NOT NULL,
  `time_slot` varchar(50) NOT NULL,
  `pickup_status_id` bigint(20) NOT NULL,
  `estimated_weight_kg` decimal(10,2) DEFAULT NULL,
  `actual_weight_kg` decimal(10,2) DEFAULT NULL,
  `waste_type_id` bigint(20) NOT NULL,
  `priority_level_id` bigint(20) DEFAULT 3,
  `notes` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `location_address` text DEFAULT NULL,
  `preferred_pickup_time` varchar(191) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pickup_schedules`
--

INSERT INTO `pickup_schedules` (`id`, `bid_id`, `company_id`, `branch_id`, `driver_id`, `scheduled_date`, `time_slot`, `pickup_status_id`, `estimated_weight_kg`, `actual_weight_kg`, `waste_type_id`, `priority_level_id`, `notes`, `latitude`, `longitude`, `location_address`, `preferred_pickup_time`, `created_at`, `updated_at`, `user_id`) VALUES
(8, NULL, 1, 9, 18, '2026-01-22', '09:00-12:00', 3, 22.00, 20.00, 2, 1, 'wwwww', 0.00000000, 0.00000000, 'aaaaa', NULL, '2026-01-21 20:51:33', '2026-01-21 20:53:36', 67),
(13, NULL, 1, 53, 18, '2026-01-28', '09:00-12:00', 3, 33.00, 200.00, 3, 1, 'aaaaaaaaaaaaaaaa', 0.00000000, 0.00000000, 'aaaaaaaaaaaa', NULL, '2026-01-24 09:44:14', '2026-04-22 09:53:45', 67),
(14, NULL, 1, 14, 18, '2026-01-28', '09:00-12:00', 1, 666.00, NULL, 3, 2, 'aaaaaaaaaaaaaaa', 0.00000000, 0.00000000, 'aaaaaaaaa', NULL, '2026-01-24 09:57:16', NULL, 67),
(15, NULL, 1, 13, 18, '2026-04-23', '09:00-12:00', 1, 54.00, NULL, 1, 1, 'notes', 0.00000000, 0.00000000, 'location', NULL, '2026-04-22 09:41:36', NULL, 67),
(16, NULL, 1, 20, 18, '2026-04-23', '09:00-12:00', 1, 44.00, NULL, 1, 1, 'nnnnnnnn', 0.00000000, 0.00000000, 'lo', NULL, '2026-04-22 09:42:26', NULL, 67);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) NOT NULL,
  `product_name` varchar(191) NOT NULL,
  `product_code` varchar(50) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock_quantity` int(11) NOT NULL DEFAULT 0,
  `min_stock_quantity` int(11) DEFAULT 10,
  `weight_kg` decimal(6,2) DEFAULT NULL,
  `composition_details` text DEFAULT NULL,
  `usage_instructions` text DEFAULT NULL,
  `image_urls` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]' CHECK (json_valid(`image_urls`)),
  `status_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_name`, `product_code`, `category_id`, `description`, `price`, `stock_quantity`, `min_stock_quantity`, `weight_kg`, `composition_details`, `usage_instructions`, `image_urls`, `status_id`, `created_at`, `updated_at`) VALUES
(1, 'Baled Mixed Paper', 'BMP-C01-001', 1, 'High-density bale of mixed paper, card, and magazines.', 150.75, 492, 50, 800.00, 'Mix of paper fibers (OCC, Newsprint, Mixed Office)', 'For pulp and paper mill use. Store in dry conditions.', '[\"url1-C01-P1\"]', 1, '2026-01-15 13:27:13', '2026-01-24 10:36:16'),
(2, 'HDPE Clear Flakes (Recycled)', 'HDPE-C01-002', 10, 'Washed, shredded, and dried clear high-density polyethylene flakes.', 2.55, 5, 100, 25.00, '100% Post-Consumer HDPE Plastic', 'Use in injection molding or blow molding applications.', NULL, 1, '2026-01-15 13:27:13', '2026-01-24 14:06:04'),
(7, 'Aluminum Used Beverage Cans (UBC) Bales', 'UBC-C04-007', 4, 'Baled, unadulterated aluminum cans, source separated.', 1800.40, 90, 5, 500.00, '99% Aluminum (Alloy 3004/3105)', 'Re-melt material for secondary aluminum production.', '[\"url7-C04-P7\"]', 1, '2026-01-15 13:27:13', NULL),
(9, 'Clear Glass Cullet (Processed)', 'CGC-C05-009', 5, 'Clean, crushed, and screened clear container glass (flint).', 65.25, 1000, 100, 1500.00, '100% Post-Consumer Soda-Lime Glass', 'Melting stock for bottle/container manufacturing.', NULL, 1, '2026-01-15 13:27:13', '2026-01-24 15:01:58'),
(10, 'Mixed Color Glass Aggregate', 'MGA-C05-010', 5, 'Mixed colored glass used as construction aggregate substitute.', 35.00, 1500, 150, 1200.00, 'Mixed color glass fines and aggregate particles.', 'Use as road base, sub-base, or drainage material.', '[\"url10-C05-P10\"]', 1, '2026-01-15 13:27:13', NULL),
(11, 'Mixed Circuit Boards (Low Grade)', 'MCB-C06-011', 6, 'Assorted circuit boards, including desktop and server scrap.', 4.99, 200, 20, 10.50, 'Fiberglass, Copper, Tin, Gold, Palladium', 'For precious metal recovery via smelting/refining.', '[\"url11-C06-P11\"]', 1, '2026-01-15 13:27:13', NULL),
(12, 'Li-Ion Battery Scrap (Drained)', 'LIBS-C06-012', 6, 'Drained, dismantled Lithium-Ion battery cells (requires specific handling).', 8.75, 150, 15, 5.00, 'Lithium, Cobalt, Nickel, Manganese, Graphite', 'Specialized refining for critical battery metals.', '[\"url12-C06-P12\"]', 1, '2026-01-15 13:27:13', NULL),
(13, 'Recycled Concrete Aggregate (RCA)', 'RCA-C07-013', 7, 'Crushed and screened concrete pieces, size 3/4 inch.', 45.10, 2000, 200, 2500.00, 'Clean recycled concrete and rock fragments.', 'Substitute for virgin aggregate in non-structural applications.', '[\"url13-C07-P13\"]', 1, '2026-01-15 13:27:13', NULL),
(14, 'Reclaimed Wood Timbers (Mixed)', 'RWT-C07-014', 7, 'Assortment of old-growth structural wood for resale.', 5.50, 400, 40, 50.00, 'Mixed hardwood and softwood lumber (nail-free).', 'For decorative and non-load-bearing construction projects.', '[\"url14-C07-P14\"]', 1, '2026-01-15 13:27:13', NULL),
(15, 'Sorted Post-Consumer Denim Bales', 'DEN-C08-015', 8, 'Compressed bales of 100% cotton denim fabric.', 1.10, 100, 10, 300.00, '100% Cotton Fiber', 'Use for shoddy/rag production or fiber recycling.', '[\"url15-C08-P15\"]', 1, '2026-01-15 13:27:13', NULL),
(16, 'Recycled PET Fiber Staple', 'PETF-C08-016', 8, 'Polyethylene Terephthalate fiber made from recycled bottles.', 3.20, 500, 50, 25.00, '100% Recycled PET Polymer', 'Spin into yarn for new fabrics or filling material.', '[\"url16-C08-P16\"]', 1, '2026-01-15 13:27:13', NULL),
(17, 'Recycled PVC Powder (White)', 'PVC-C09-017', 9, 'Fine powder of rigid, cleaned post-industrial PVC.', 1.85, 750, 75, 20.00, 'Polyvinyl Chloride Polymer', 'Use as filler or additive in new PVC compound manufacturing.', '[\"url17-C09-P17\"]', 1, '2026-01-15 13:27:13', NULL),
(18, 'PVC Pipe Offcuts (Regrind)', 'PVO-C09-018', 9, 'Ground PVC pipe fragments, suitable for re-extrusion.', 1.45, 600, 60, 25.00, 'Polyvinyl Chloride', 'Melt and re-extrude into non-pressure pipe or conduit.', '[\"url18-C09-P18\"]', 1, '2026-01-15 13:27:13', NULL),
(19, 'Tire Derived Fuel (TDF) Shreds', 'TDF-C10-019', 10, 'Shredded vehicle tires, size 2 inch minus.', 55.00, 1200, 120, 900.00, 'Natural and Synthetic Rubber, Steel Wire, Textile Fiber', 'Use as supplemental fuel in cement kilns or industrial boilers.', '[\"url19-C10-P19\"]', 1, '2026-01-15 13:27:13', NULL),
(20, 'Rubber Playground Mulch (Black)', 'RPM-C10-020', 10, 'Clean, durable rubber granules for playground surfaces.', 12.50, 450, 45, 10.00, '100% Recycled Rubber (SBR)', 'Spread over playground area to cushion falls.', '[\"url20-C10-P20\"]', 1, '2026-01-15 13:27:13', NULL),
(21, 'Refuse Derived Fuel (RDF)', 'RDF-C11-021', 11, 'Processed municipal solid waste for energy recovery.', 70.00, 1500, 150, 1000.00, 'Plastics, Paper, Textiles, Non-Recyclable Fines', 'Used for incineration in Waste-to-Energy facilities.', '[\"url21\"]', 1, '2026-01-15 13:27:13', NULL),
(22, 'Residual Landfill Cover', 'RLC-C11-022', 11, 'Inert materials used for daily landfill cover.', 15.00, 3000, 300, 2000.00, 'Soil, Ash, Fine Residues', 'Apply as mandated landfill cover material.', '[\"url22\"]', 1, '2026-01-15 13:27:13', NULL),
(23, 'Dewatered Bio-Solids (Class B)', 'DBS-C12-023', 12, 'Treated sludge product for land application.', 5.25, 800, 80, 500.00, 'Organic matter, Nutrients (N, P, K)', 'Apply to non-food crops under state regulations.', '[\"url23\"]', 1, '2026-01-15 13:27:13', NULL),
(24, 'Dried Sludge Pellets', 'DSP-C12-024', 12, 'Heat-dried and pelletized bio-solids for fertilizer.', 12.99, 500, 50, 20.00, 'Concentrated nutrients and organic matter.', 'Use as slow-release granular fertilizer.', '[\"url24\"]', 1, '2026-01-15 13:27:13', NULL),
(25, 'Old Corrugated Containers (OCC) Grade 11 Bales', 'OCC-C13-025', 13, 'Baled, clean cardboard boxes.', 180.50, 700, 70, 950.00, 'High-quality corrugated fiber.', 'Primary feedstock for containerboard production.', '[\"url25\"]', 1, '2026-01-15 13:27:13', NULL),
(26, 'Sorted Office Paper (SOP) Bales', 'SOP-C13-026', 13, 'Baled white and colored office paper.', 220.75, 400, 40, 850.00, 'Mixed wood pulp fibers.', 'For fine paper and tissue production.', '[\"url26\"]', 1, '2026-01-15 13:27:13', NULL),
(27, 'PS Foam Densified Blocks', 'PSDB-C14-027', 14, 'Melted and densified blocks of expanded polystyrene foam.', 1.30, 300, 30, 50.00, 'Polystyrene Polymer', 'Used to manufacture insulation, picture frames, or new foam.', '[\"url27\"]', 1, '2026-01-15 13:27:13', NULL),
(28, 'PS Injection Grade Pellets (Black)', 'PSPG-C14-028', 14, 'Recycled polystyrene pellets for injection molding.', 1.60, 550, 55, 25.00, 'High Impact Polystyrene (HIPS)', 'Use for making non-food grade plastic items.', '[\"url28\"]', 1, '2026-01-15 13:27:13', NULL),
(29, 'PP Flake Mixed Color', 'PPFM-C15-029', 15, 'Washed and shredded polypropylene flakes.', 1.95, 900, 90, 25.00, 'Polypropylene Polymer', 'Use for compounding and molding automotive parts.', '[\"url29\"]', 1, '2026-01-15 13:27:13', NULL),
(30, 'PP Jumbo Bag Pellets', 'PPJBP-C15-030', 15, 'Recycled pellets from woven PP sacks/bags.', 2.15, 650, 65, 20.00, 'High-tenacity Polypropylene', 'Extrusion into non-woven fabrics or strapping.', '[\"url30\"]', 1, '2026-01-15 13:27:13', NULL),
(31, 'Wood Chips (Boiler Fuel)', 'WCBF-C16-031', 16, 'Clean, untreated wood chips for thermal energy.', 35.00, 1800, 180, 800.00, 'Mixed softwood and hardwood.', 'Feedstock for biomass boilers.', '[\"url31\"]', 1, '2026-01-15 13:27:13', NULL),
(32, 'Colored Wood Mulch (Red)', 'CWM-C16-032', 16, 'Treated wood chips colored for landscaping.', 10.99, 1000, 100, 10.00, 'Recycled wood waste with non-toxic colorant.', 'Decorative ground cover for gardens.', '[\"url32\"]', 1, '2026-01-15 13:27:13', NULL),
(33, 'Bare Bright Copper Wire', 'BBC-C17-033', 17, 'High-purity, clean, unalloyed copper wire.', 6500.00, 20, 2, 50.00, '99.9% Copper', 'Highest-grade melting stock for copper refining.', '[\"url33\"]', 1, '2026-01-15 13:27:13', NULL),
(34, 'Insulated Copper Cable (Low Grade)', 'ICC-C17-034', 17, 'Mixed plastic-insulated copper cables.', 1200.00, 50, 5, 200.00, 'Copper metal with PVC/PE insulation.', 'Stripping and chopping for copper recovery.', '[\"url34\"]', 1, '2026-01-15 13:27:13', NULL),
(35, 'Mixed Lead Batteries (Spent)', 'MLB-C18-035', 18, 'Spent lead-acid vehicle and industrial batteries.', 0.85, 300, 30, 20.00, 'Lead Plates, Sulfuric Acid, Plastic Casing', 'Primary feed for lead smelting (must be dry).', '[\"url35\"]', 1, '2026-01-15 13:27:13', NULL),
(36, 'Die-Cast Zinc Scrap', 'DCZ-C18-036', 18, 'Clean, obsolete die-cast zinc parts (e.g., automotive grilles).', 1.50, 150, 15, 50.00, 'Zinc Alloy (Zamak)', 'Melting stock for new die-cast parts.', '[\"url36\"]', 1, '2026-01-15 13:27:13', NULL),
(37, 'HDPE Mixed Color Pellets (Post-Consumer)', 'HMP-C19-037', 19, 'Extruded pellets from various colored HDPE bottles/containers.', 1.70, 850, 85, 25.00, '100% Post-Consumer HDPE', 'Used for molding non-pigment-sensitive products (e.g., pipe, profiles).', '[\"url37\"]', 1, '2026-01-15 13:27:13', NULL),
(38, 'HDPE Pipe Grade Granules', 'HDPG-C19-038', 19, 'High molecular weight HDPE granules for pipe extrusion.', 2.10, 500, 50, 20.00, 'Virgin/Near-Virgin HDPE blend.', 'High-performance pipe and conduit manufacturing.', '[\"url38\"]', 1, '2026-01-15 13:27:13', NULL),
(39, 'Clear PET Bottle Flakes', 'PETC-C20-039', 20, 'Washed, clean, clear Polyethylene Terephthalate bottle flakes.', 1.25, 1100, 110, 25.00, '100% Post-Consumer PET', 'Repolymerization into new food-grade bottles or fiber.', '[\"url39\"]', 1, '2026-01-15 13:27:13', NULL),
(40, 'Green PET Strap (Recycled)', 'PETS-C20-040', 20, 'Strapping material made from recycled green PET.', 0.95, 700, 70, 10.00, 'Recycled Green PET', 'Used for packaging and pallet securing.', '[\"url40\"]', 1, '2026-01-15 13:27:13', NULL),
(41, 'Cattle Manure (Dried and Screened)', 'CMD-C21-041', 21, 'Dried and fine-screened cattle manure for soil conditioning.', 55.00, 600, 60, 500.00, 'Organic matter and macronutrients.', 'Apply to gardens and fields as natural fertilizer.', '[\"url41\"]', 1, '2026-01-15 13:27:13', NULL),
(42, 'Rice Hull Briquettes', 'RHB-C21-042', 21, 'Compressed briquettes made from rice hulls for fuel.', 80.00, 400, 40, 100.00, 'Densified rice husk biomass.', 'Clean-burning fuel source for cooking or heating.', '[\"url42\"]', 1, '2026-01-15 13:27:13', NULL),
(43, 'Fluorescent Lamp Cullet (Mercury Free)', 'FLC-C22-043', 22, 'Crushed glass from treated fluorescent lamps (mercury removed).', 0.50, 200, 20, 50.00, 'Soda-lime glass, Phosphorus coating residues.', 'Use as glass aggregate or landfill disposal.', '[\"url43\"]', 2, '2026-01-15 13:27:13', NULL),
(44, 'Recycled Solvent (Industrial Grade)', 'RSI-C22-044', 22, 'Distilled and purified solvent for industrial cleaning.', 8.99, 100, 10, 5.00, 'Mixed hydrocarbons, purified.', 'Use for equipment cleaning and degreasing.', '[\"url44\"]', 2, '2026-01-15 13:27:13', NULL),
(45, 'Tyvek Sheet Scrap (Clean)', 'TSS-C23-045', 23, 'Clean offcuts of flash-spun HDPE Tyvek sheeting.', 3.50, 150, 15, 10.00, 'Flash-spun HDPE Fibers', 'Melt and re-extrude into new film or sheet products.', '[\"url45\"]', 1, '2026-01-15 13:27:13', NULL),
(46, 'LDPE Film (Baled Clear)', 'LDFB-C23-046', 23, 'Baled clear Low-Density Polyethylene stretch/shrink wrap.', 0.75, 1000, 100, 450.00, 'Low-Density Polyethylene', 'Used for new film and bag manufacturing.', '[\"url46\"]', 1, '2026-01-15 13:27:13', NULL),
(47, 'Porcelain Tile Aggregate', 'PTA-C24-047', 24, 'Crushed porcelain tile fines for construction fillers.', 25.00, 900, 90, 1000.00, 'Porcelain/Ceramic Fines', 'Filler material for non-structural cement mixes.', '[\"url47\"]', 1, '2026-01-15 13:27:13', NULL),
(48, 'Recycled Sanitaryware Pieces', 'RSP-C24-048', 24, 'Broken ceramic toilet and sink pieces (shipped in crates).', 15.00, 300, 30, 800.00, 'Vitrified China Ceramic', 'Grinding for use as a flux in cement production.', '[\"url48\"]', 1, '2026-01-15 13:27:13', NULL),
(49, 'Nickel Alloy Scrap (Inconel 625)', 'NAS-C25-049', 25, 'High-temperature, nickel-chromium alloy scrap.', 15.50, 5, 1, 10.00, 'Nickel, Chromium, Molybdenum', 'Sold for aerospace and high-performance metal casting.', '[\"url49\"]', 1, '2026-01-15 13:27:13', NULL),
(50, 'Stainless Steel Scrap (Grade 304)', 'SSS-C25-050', 25, 'Clean, unalloyed 304 stainless steel turnings and offcuts.', 2.10, 80, 8, 100.00, 'Iron, Chromium (18%), Nickel (8%)', 'Used in specialized stainless steel refining.', '[\"url50\"]', 1, '2026-01-15 13:27:13', NULL),
(51, 'LDPE Plastic Sheeting (Thick)', 'LPS-C26-051', 26, 'Heavy-duty LDPE plastic for liners.', 0.90, 800, 80, 50.00, 'LDPE Polymer', 'For use as vapor barriers or landfill liners.', '[\"url51\"]', 1, '2026-01-15 13:27:13', NULL),
(52, 'Plastic Pallet Regrind', 'PPR-C26-052', 26, 'Ground plastic derived from obsolete shipping pallets.', 1.10, 650, 65, 25.00, 'Mixed HDPE/PP Polymer', 'Molded into new non-structural parts.', '[\"url52\"]', 1, '2026-01-15 13:27:13', NULL),
(53, 'Mixed Office Paper (A-Grade)', 'MOP-C27-053', 27, 'High-volume mixed office paper for de-inking.', 180.00, 550, 55, 800.00, 'Mixed white and colored paper.', 'Used in paper recycling processes.', '[\"url53\"]', 1, '2026-01-15 13:27:13', NULL),
(54, 'Brown Kraft Paper Rolls', 'BKR-C27-054', 27, 'Clean, unused brown kraft paper roll ends.', 450.00, 150, 15, 200.00, 'Virgin Kraft Paper Fiber', 'Used for void fill or wrapping applications.', '[\"url54\"]', 1, '2026-01-15 13:27:13', NULL),
(55, 'Crumb Rubber Fine Mesh (#30)', 'CRF-C28-055', 28, 'Very fine mesh crumb rubber for athletic tracks.', 0.85, 400, 40, 10.00, 'Recycled Tire Rubber', 'Mixing into athletic track surface materials.', '[\"url55\"]', 1, '2026-01-15 13:27:13', NULL),
(56, 'Rubber Base Matting Rolls', 'RBM-C28-056', 28, 'Rolled matting made from compressed crumb rubber.', 25.00, 100, 10, 30.00, 'Bound Crumb Rubber Granules', 'Used as underlayment or flooring protection.', '[\"url56\"]', 1, '2026-01-15 13:27:13', NULL),
(57, 'Recycled Glass Sand (Fine)', 'RGS-C29-057', 29, 'Ultra-fine glass powder used as an abrasive or filler.', 75.00, 1200, 120, 1000.00, '100% Crushed Glass', 'Used in sandblasting or as an industrial filler.', '[\"url57\"]', 1, '2026-01-15 13:27:13', NULL),
(58, 'Paving Bricks (Recycled Glass)', 'PBRG-C29-058', 29, 'Decorative paving bricks made primarily of recycled glass.', 1.50, 3000, 300, 3.00, 'Glass Aggregate and Binder', 'Landscaping and pathway construction.', '[\"url58\"]', 1, '2026-01-15 13:27:13', NULL),
(59, 'Reclaimed Concrete Blocks (Non-Structural)', 'RCB-C30-059', 30, 'Standard size concrete blocks from demolition.', 0.75, 5000, 500, 15.00, 'Cement, Aggregate, Water', 'Used for temporary barriers or non-load-bearing walls.', '[\"url59\"]', 1, '2026-01-15 13:27:13', NULL),
(60, 'Asphalt Millings (Reclaimed Pavement)', 'AMP-C30-060', 30, 'Ground asphalt pavement used for road repairs.', 30.00, 2500, 250, 2000.00, 'Asphalt, Aggregate', 'Used in cold-patch asphalt mixes and road bases.', '[\"url60\"]', 1, '2026-01-15 13:27:13', NULL),
(61, 'Waste Vegetable Oil (Filtered)', 'WVO-C31-061', 31, 'Filtered used cooking oil for biodiesel production.', 0.70, 400, 40, 500.00, 'Triglycerides, Fatty Acids', 'Feedstock for biodiesel refinement.', '[\"url61\"]', 1, '2026-01-15 13:27:13', NULL),
(62, 'Animal Tallow (Rendering Grade)', 'ATR-C31-062', 31, 'Rendered animal fat for soap or energy production.', 0.65, 300, 30, 500.00, 'Animal Fats (primarily beef and pork)', 'Used in oleochemicals or biofuel production.', '[\"url62\"]', 1, '2026-01-15 13:27:13', NULL),
(63, 'Nickel Cadmium Batteries (Drained)', 'NCB-C32-063', 32, 'Drained industrial Ni-Cad batteries.', 5.10, 80, 8, 15.00, 'Nickel, Cadmium', 'Recycling for specialty metal recovery.', '[\"url63\"]', 2, '2026-01-15 13:27:13', NULL),
(64, 'Cobalt Sludge Concentrate', 'CSC-C32-064', 32, 'Sludge byproduct rich in cobalt from refining processes.', 12.50, 20, 2, 10.00, 'Cobalt compounds, trace metals', 'Further purification for high-value metal salts.', '[\"url64\"]', 2, '2026-01-15 13:27:13', NULL),
(65, 'Mixed Colored PET Flakes', 'PETM-C33-065', 33, 'Washed, shredded, and dried mixed color PET flakes.', 0.95, 1500, 150, 25.00, 'Mixed color PET Polymer', 'Used for fiber, strapping, and non-transparent products.', '[\"url65\"]', 1, '2026-01-15 13:27:13', NULL),
(66, 'PET Sheet Scrap (Clear)', 'PETS-C33-066', 33, 'Clear PET sheet offcuts from packaging production.', 1.15, 600, 60, 20.00, 'Virgin/Post-Industrial PET', 'Thermoforming applications for new packaging.', '[\"url66\"]', 1, '2026-01-15 13:27:13', NULL),
(67, 'Cardboard Tubes (Industrial)', 'CTI-C34-067', 34, 'Heavy-duty cardboard tubes from fabric/paper rolls.', 150.00, 350, 35, 100.00, 'High-density cardboard layers.', 'Used for core winding or shredded for pulp.', '[\"url67\"]', 1, '2026-01-15 13:27:13', NULL),
(68, 'Paperboard Pulp Slurry', 'PPS-C34-068', 34, 'Wet paper pulp slurry from recycled cartonboard.', 0.25, 10000, 1000, 5000.00, 'Water and paperboard fibers.', 'Direct input for carton manufacturing.', '[\"url68\"]', 1, '2026-01-15 13:27:13', NULL),
(69, 'Hardwood Sawdust (Dry)', 'HSD-C35-069', 35, 'Fine, kiln-dried hardwood sawdust.', 5.00, 1200, 120, 5.00, 'Mixed Oak/Maple sawdust.', 'Used for animal bedding or wood-plastic composites.', '[\"url69\"]', 1, '2026-01-15 13:27:13', NULL),
(70, 'Plywood Offcuts (Small)', 'POS-C35-070', 35, 'Small, clean plywood pieces for woodworking projects.', 1.25, 800, 80, 10.00, 'Wood veneer and adhesive.', 'Used for small crafts or further shredding.', '[\"url70\"]', 1, '2026-01-15 13:27:13', NULL),
(71, 'Food Waste Digestate (Solid)', 'FWD-C36-071', 36, 'Solid residue from anaerobic digestion of food waste.', 45.00, 700, 70, 500.00, 'Nutrient-rich organic matter.', 'Soil improver for non-commercial planting.', '[\"url71\"]', 1, '2026-01-15 13:27:13', NULL),
(72, 'Anaerobic Digester Liquid Fertilizer', 'ADLF-C36-072', 36, 'Liquid effluent from food waste AD, high in nitrogen.', 0.50, 2000, 200, 1000.00, 'Water, soluble NPK compounds.', 'Liquid feed for large-scale farming.', '[\"url72\"]', 1, '2026-01-15 13:27:13', NULL),
(73, 'Treated Automotive Shredder Residue (ASR)', 'TASR-C37-073', 37, 'Non-metallic fluff from car shredding (treated for hazardous components).', 15.00, 500, 50, 1000.00, 'Plastics, foams, glass, rubber, fibers.', 'Final disposal in engineered landfills or specialized WTE.', '[\"url73\"]', 1, '2026-01-15 13:27:13', NULL),
(74, 'PVC Coated Fabric Scrap', 'PCFS-C37-074', 37, 'Scrap from PVC-coated tarp and banner material.', 1.80, 400, 40, 25.00, 'PVC coating, Polyester base fabric.', 'Used as material for low-stress products or pyrolysis.', '[\"url74\"]', 1, '2026-01-15 13:27:13', NULL),
(75, 'Recycled Tin Plate Scrap', 'RTS-C38-075', 38, 'Clean, baled scrap from tin-plated steel cans.', 380.00, 200, 20, 1000.00, 'Steel with a thin tin coating.', 'Used in steel refining; tin recovered via detinning.', '[\"url75\"]', 1, '2026-01-15 13:27:13', NULL),
(76, 'Mixed Yellow Brass Ingot', 'MYBI-C38-076', 38, 'Smelted ingot from mixed copper/zinc alloy scrap.', 4.50, 50, 5, 20.00, 'Copper (60-65%), Zinc (35-40%)', 'Casting and machinery components production.', '[\"url76\"]', 1, '2026-01-15 13:27:13', NULL),
(77, 'Polycarbonate (PC) Granules', 'PCG-C39-077', 39, 'Recycled granules from CD/DVD and water bottle plastic.', 3.50, 300, 30, 20.00, 'Polycarbonate Polymer', 'Used for clear, impact-resistant molded products.', '[\"url77\"]', 1, '2026-01-15 13:27:13', NULL),
(78, 'ABS Plastic Flake (Black)', 'ABSF-C39-078', 39, 'Washed ABS plastic flake from appliance casings.', 2.90, 450, 45, 25.00, 'Acrylonitrile Butadiene Styrene', 'Molding of durable, non-food contact items.', '[\"url78\"]', 1, '2026-01-15 13:27:13', NULL),
(79, 'Recycled Polyester Fabric Remnants', 'RPFR-C40-079', 40, 'Clean remnants and offcuts of 100% recycled polyester fabric.', 2.10, 200, 20, 10.00, 'Recycled PET Polyester', 'Used for patchwork, small textile manufacturing, or filling.', '[\"url79\"]', 1, '2026-01-15 13:27:13', NULL),
(80, 'Wool/Cotton Blend Textile Shred', 'WCTS-C40-080', 40, 'Shredded mixed wool and cotton textiles.', 0.55, 600, 60, 50.00, 'Mixed Natural Fibers', 'Used for non-woven insulation or padding.', '[\"url80\"]', 1, '2026-01-15 13:27:13', NULL),
(81, 'Treated Wood Fence Posts (Shredded)', 'TWFPS-C41-081', 41, 'Shredded CCA-treated wood (requires specialized disposal).', 10.00, 800, 80, 1000.00, 'Wood fiber, Copper Chromated Arsenate (CCA)', 'Used in designated power plants or hazardous waste landfill.', '[\"url81\"]', 2, '2026-01-15 13:27:13', NULL),
(82, 'Marine Pilings (Chipped)', 'MPC-C41-082', 41, 'Chipped creosote-treated marine pilings.', 8.00, 650, 65, 900.00, 'Wood fiber, Creosote', 'Specialized industrial energy recovery or hazardous disposal.', '[\"url82\"]', 2, '2026-01-15 13:27:13', NULL),
(83, 'Spent Catalysts (Petroleum Refining)', 'SCP-C42-083', 42, 'Used catalysts from petrochemical processes (contains trace metals).', 50.00, 10, 1, 5.00, 'Alumina, Cobalt, Molybdenum, Nickel', 'Sold for valuable metal reclamation.', '[\"url83\"]', 2, '2026-01-15 13:27:13', NULL),
(84, 'High-Purity Palladium Flake', 'HPF-C42-084', 42, 'Flake form of recovered Palladium metal.', 50000.00, 1, 0, 0.10, '99.9% Palladium', 'High-value metal for electronics and jewelry.', '[\"url84\"]', 1, '2026-01-15 13:27:13', NULL),
(85, 'Green Waste Compost Tea Bags', 'GWTB-C43-085', 43, 'Biodegradable bags filled with compost for brewing tea.', 5.99, 1500, 150, 0.50, 'Dried yard waste compost.', 'Soak in water to create liquid fertilizer.', '[\"url85\"]', 1, '2026-01-15 13:27:13', NULL),
(86, 'Vermicompost (Worm Castings)', 'VCM-C43-086', 43, 'High-quality soil amendment from worm farming.', 18.99, 500, 50, 10.00, 'Worm castings (vermicompost).', 'Potting mix additive for improved growth.', '[\"url86\"]', 1, '2026-01-15 13:27:13', NULL),
(87, 'Flexible Packaging Film Scrap', 'FPFS-C44-087', 44, 'Mixed LDPE and LLDPE film scrap from food packaging.', 0.80, 1200, 120, 400.00, 'Mixed Polyethylene Films', 'Used for co-extrusion into multi-layer films.', '[\"url87\"]', 1, '2026-01-15 13:27:13', NULL),
(88, 'Printed Plastic Bags (Baled)', 'PPBB-C44-088', 44, 'Baled grocery and retail printed plastic carrier bags.', 0.65, 1000, 100, 450.00, 'HDPE/LDPE Film', 'Use for coloring masterbatch or dark-colored products.', '[\"url88\"]', 1, '2026-01-15 13:27:13', NULL),
(89, 'Battery Electrolyte (Sulfuric Acid)', 'BES-C45-089', 45, 'Recovered and purified sulfuric acid from battery recycling.', 0.45, 500, 50, 1000.00, 'Dilute Sulfuric Acid', 'Industrial applications or fertilizer production.', '[\"url89\"]', 2, '2026-01-15 13:27:13', NULL),
(90, 'Nickel Hydroxide Cake', 'NHC-C45-090', 45, 'Filter cake rich in Nickel from hydrometallurgical processing.', 3.50, 100, 10, 50.00, 'Nickel Hydroxide compounds.', 'Input material for new battery cathode production.', '[\"url90\"]', 1, '2026-01-15 13:27:13', NULL),
(91, 'Clean Brown Glass Cullet', 'CBGC-C46-091', 46, 'Processed brown (amber) container glass.', 60.00, 950, 95, 1500.00, '100% Post-Consumer Amber Glass', 'Melting stock for brown beer and beverage bottles.', '[\"url91\"]', 1, '2026-01-15 13:27:13', NULL),
(92, 'Flat Panel Display Glass', 'FPDG-C46-092', 46, 'Specialized glass from monitors and TVs (requires lead removal).', 0.15, 300, 30, 200.00, 'Soda-lime glass with trace lead.', 'Used as non-structural filler or disposed in specialized facilities.', '[\"url92\"]', 2, '2026-01-15 13:27:13', NULL),
(93, 'Recycled Carpet Tile (Modular)', 'RCMT-C47-093', 47, 'Used but clean modular carpet tiles (sold in boxes).', 5.99, 200, 20, 15.00, 'Nylon/Polypropylene face fiber, PVC/Bitumen backing.', 'Re-installation in commercial settings.', '[\"url93\"]', 1, '2026-01-15 13:27:13', NULL),
(94, 'Nylon Fiber (Type 6/66) Pellet', 'NFPS-C47-094', 47, 'Pellets from recycled Nylon 6 and 66 carpet fiber.', 4.20, 300, 30, 20.00, 'Polyamide Polymer', 'Injection molding of durable parts or new fiber spinning.', '[\"url94\"]', 1, '2026-01-15 13:27:13', NULL),
(95, 'Precious Metal Slag (Refining Byproduct)', 'PMSB-C48-095', 48, 'Slag material from smelting (trace amounts of Au, Ag, Pt).', 15.00, 50, 5, 50.00, 'Silica, Iron oxides, trace precious metals.', 'Further leaching or high-temperature smelting.', '[\"url95\"]', 2, '2026-01-15 13:27:13', NULL),
(96, 'Mercury Amalgam Capsules (Dental)', 'MAC-C48-096', 48, 'Used dental capsules containing mercury and silver/tin alloy.', 500.00, 5, 0, 0.05, 'Mercury, Silver, Tin, Copper', 'Specialized retort processing for mercury recovery.', '[\"url96\"]', 2, '2026-01-15 13:27:13', NULL),
(97, 'High-Moisture Food Waste (Pulped)', 'HMFW-C49-097', 49, 'Homogenized, high-moisture commercial food waste.', 10.00, 3000, 300, 1000.00, 'Mixed organic matter (water content > 70%).', 'Anaerobic digestion feedstock for biogas production.', '[\"url97\"]', 1, '2026-01-15 13:27:13', NULL),
(98, 'Coffee Grounds (Dried)', 'CGD-C49-098', 49, 'Dried, spent coffee grounds for soil or energy.', 0.99, 1500, 150, 10.00, 'Coffee bean solids, trace oils.', 'Used as soil additive or biomass fuel.', '[\"url98\"]', 1, '2026-01-15 13:27:13', NULL),
(99, 'White Goods Scrap (Appliances)', 'WGS-C50-099', 50, 'Scrap metal from refrigerators, washers, and dryers (pre-processed).', 200.00, 350, 35, 2000.00, 'Ferrous metal, non-ferrous metals, plastics.', 'Shredding and separation for various material streams.', '[\"url99\"]', 1, '2026-01-15 13:27:13', NULL),
(100, 'Used Radiators (Aluminum/Copper)', 'URAC-C50-100', 50, 'Mixed car radiators for metal separation.', 3.50, 150, 15, 50.00, 'Aluminum Fins, Copper/Brass Tubes', 'Separation process for high-value metal recovery.', '[\"url100\"]', 1, '2026-01-15 13:27:13', NULL),
(101, 'Polylactic Acid (PLA) Flakes', 'PLAF-C51-101', 50, 'Clean, shredded PLA plastic from biodegradable packaging.', 2.50, 250, 25, 15.00, 'Polylactic Acid Polymer', 'Use for composting or chemical depolymerization.', '[\"url101\"]', 1, '2026-01-15 13:27:13', NULL),
(102, 'Compostable Food Service Ware (Shredded)', 'CFSW-C51-102', 2, 'Shredded plant-based compostable cups and containers.', 0.80, 500, 50, 50.00, 'PLA, PHA, Bagasse Fibers', 'Feedstock for commercial composting facilities.', '[\"url102\"]', 1, '2026-01-15 13:27:13', NULL),
(108, 'Banana peel 12', '111222', 1, 'Made from Banana peels', 23.00, 11, 10, NULL, NULL, NULL, NULL, 1, '2026-01-24 09:16:13', '2026-01-24 13:21:46'),
(110, 'alsdf', 'askdl9', 10, 'alksad', 388.00, 88, 10, NULL, NULL, NULL, NULL, 2, '2026-01-24 14:57:02', '2026-01-24 15:01:23'),
(111, 'new info update', 'lask update', 11, 'alsd update', 2320.00, 44, 10, NULL, NULL, NULL, NULL, 1, '2026-01-24 15:02:22', '2026-01-24 15:03:31'),
(112, 'aaaaa', 'aaaaa', 8, 'aaaaa', 1234456.00, 1234, 10, NULL, NULL, NULL, NULL, 1, '2026-01-27 15:04:31', '2026-01-27 15:04:31');

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `id` bigint(20) NOT NULL,
  `category_name` varchar(191) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`id`, `category_name`, `description`, `image_url`, `created_at`, `updated_at`) VALUES
(1, 'Banana Fertilizer', 'Banana Fertilizer', NULL, '2026-01-15 13:27:13', NULL),
(2, 'Organic Fertilizers', 'Fertilizers made from organic waste materials', NULL, '2026-01-15 13:27:13', NULL),
(3, 'Compost Products', 'Various grades of compost from municipal waste', NULL, '2026-01-15 13:27:13', NULL),
(4, 'Recycled Paper Products', 'Paper products made from recycled materials', NULL, '2026-01-15 13:27:13', NULL),
(5, 'Recycled Plastic Products', 'Products manufactured from recycled plastics', NULL, '2026-01-15 13:27:13', NULL),
(6, 'Recycled Glass Products', 'Glass items made from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(7, 'E-Waste Components', 'Salvaged components from electronic waste', NULL, '2026-01-15 13:27:13', NULL),
(8, 'Reclaimed Wood Products', 'Products made from reclaimed/recycled wood', NULL, '2026-01-15 13:27:13', NULL),
(9, 'Biogas Products', 'Biogas and related products from organic waste', NULL, '2026-01-15 13:27:13', NULL),
(10, 'Rubber Mulch', 'Mulch made from recycled tires', NULL, '2026-01-15 13:27:13', NULL),
(11, 'Construction Aggregates', 'Recycled materials for construction use', NULL, '2026-01-15 13:27:13', NULL),
(12, 'Metal Scrap Products', 'Processed metal scraps for manufacturing', NULL, '2026-01-15 13:27:13', NULL),
(13, 'Textile Recyclates', 'Recycled textile fibers and products', NULL, '2026-01-15 13:27:13', NULL),
(14, 'Organic Potting Mix', 'Potting soil from composted organic waste', NULL, '2026-01-15 13:27:13', NULL),
(15, 'Recycled Aluminum Products', 'Products made from recycled aluminum', NULL, '2026-01-15 13:27:13', NULL),
(16, 'Biochar Products', 'Biochar produced from biomass waste', NULL, '2026-01-15 13:27:13', NULL),
(17, 'Waste-to-Energy Products', 'Products related to energy from waste', NULL, '2026-01-15 13:27:13', NULL),
(18, 'Recycled Aggregate Concrete', 'Concrete made with recycled aggregates', NULL, '2026-01-15 13:27:13', NULL),
(19, 'Plastic Lumber', 'Lumber alternatives made from recycled plastics', NULL, '2026-01-15 13:27:13', NULL),
(20, 'Recycled Glass Countertops', 'Countertops made from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(21, 'Organic Pest Control', 'Pest control products from organic waste', NULL, '2026-01-15 13:27:13', NULL),
(22, 'Recycled Carpet Products', 'Carpets made from recycled materials', NULL, '2026-01-15 13:27:13', NULL),
(23, 'Recycled Steel Products', 'Products manufactured from recycled steel', NULL, '2026-01-15 13:27:13', NULL),
(24, 'Compostable Packaging', 'Packaging materials from compostable waste', NULL, '2026-01-15 13:27:13', NULL),
(25, 'Recycled Battery Components', 'Components recovered from used batteries', NULL, '2026-01-15 13:27:13', NULL),
(26, 'Recycled Ceramic Products', 'Ceramic products from recycled materials', NULL, '2026-01-15 13:27:13', NULL),
(27, 'Organic Soil Amendments', 'Soil conditioners from organic waste', NULL, '2026-01-15 13:27:13', NULL),
(28, 'Recycled Plastic Fabric', 'Fabrics made from recycled plastic bottles', NULL, '2026-01-15 13:27:13', NULL),
(29, 'Recycled Paperboard', 'Paperboard products from recycled paper', NULL, '2026-01-15 13:27:13', NULL),
(30, 'Recycled Glass Beads', 'Decorative beads from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(31, 'Composted Manure', 'Processed manure from agricultural waste', NULL, '2026-01-15 13:27:13', NULL),
(32, 'Recycled PVC Products', 'Products made from recycled PVC materials', NULL, '2026-01-15 13:27:13', NULL),
(33, 'Recycled Rubber Products', 'Products made from recycled rubber', NULL, '2026-01-15 13:27:13', NULL),
(34, 'Organic Mulch', 'Mulch from organic yard waste', NULL, '2026-01-15 13:27:13', NULL),
(35, 'Recycled Electronic Components', 'Working components from e-waste', NULL, '2026-01-15 13:27:13', NULL),
(36, 'Recycled Glass Tiles', 'Tiles made from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(37, 'Compost Tea', 'Liquid fertilizer from compost extracts', NULL, '2026-01-15 13:27:13', NULL),
(38, 'Recycled Plastic Furniture', 'Furniture made from recycled plastics', NULL, '2026-01-15 13:27:13', NULL),
(39, 'Recycled Metal Art', 'Artistic items made from recycled metals', NULL, '2026-01-15 13:27:13', NULL),
(40, 'Biodegradable Planters', 'Plant containers from biodegradable waste', NULL, '2026-01-15 13:27:13', NULL),
(41, 'Recycled Glassware', 'Glassware made from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(42, 'Organic Vermicompost', 'Compost produced using worms', NULL, '2026-01-15 13:27:13', NULL),
(43, 'Recycled Plastic Bags', 'Bags made from recycled plastic materials', NULL, '2026-01-15 13:27:13', NULL),
(44, 'Recycled Wood Chips', 'Wood chips from recycled wood waste', NULL, '2026-01-15 13:27:13', NULL),
(45, 'Recycled Glass Aggregate', 'Crushed glass for construction applications', NULL, '2026-01-15 13:27:13', NULL),
(46, 'Compost Extract Products', 'Various extracts derived from compost', NULL, '2026-01-15 13:27:13', NULL),
(47, 'Recycled Plastic Containers', 'Containers made from recycled plastics', NULL, '2026-01-15 13:27:13', NULL),
(48, 'Recycled Metal Sheets', 'Sheets made from recycled metals', NULL, '2026-01-15 13:27:13', NULL),
(49, 'Organic Seed Starters', 'Seed starting products from organic waste', NULL, '2026-01-15 13:27:13', NULL),
(50, 'Recycled Glass Sand', 'Sand substitute made from recycled glass', NULL, '2026-01-15 13:27:13', NULL),
(51, 'Recycled Plastic Pellets', 'Raw plastic pellets for manufacturing', NULL, '2026-01-15 13:27:13', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `promotions`
--

CREATE TABLE `promotions` (
  `id` bigint(20) NOT NULL,
  `promotion_code` varchar(50) NOT NULL,
  `promotion_name` varchar(191) NOT NULL,
  `description` text DEFAULT NULL,
  `discount_type_id` bigint(20) NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `max_usage` int(11) DEFAULT NULL,
  `usage_count` int(11) DEFAULT 0,
  `status_id` bigint(20) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `public_garbage_reports`
--

CREATE TABLE `public_garbage_reports` (
  `id` bigint(20) NOT NULL,
  `reported_by_user_id` bigint(20) NOT NULL,
  `photo_url` varchar(500) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `address` text NOT NULL,
  `description` text DEFAULT NULL,
  `estimated_volume` varchar(50) DEFAULT NULL,
  `report_status_id` bigint(20) NOT NULL,
  `funding_goal` decimal(10,2) DEFAULT NULL,
  `funds_collected` decimal(10,2) DEFAULT 0.00,
  `social_media_post_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_media_post_ids`)),
  `cleanup_scheduled_date` date DEFAULT NULL,
  `cleanup_completed_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `public_garbage_reports`
--

INSERT INTO `public_garbage_reports` (`id`, `reported_by_user_id`, `photo_url`, `latitude`, `longitude`, `address`, `description`, `estimated_volume`, `report_status_id`, `funding_goal`, `funds_collected`, `social_media_post_ids`, `cleanup_scheduled_date`, `cleanup_completed_date`, `created_at`, `updated_at`) VALUES
(1, 69, 'http://localhost:3000/uploads\\temp\\photo-567f80f1-c2bf-415a-b339-a8dfb7446782.jpg', 0.00000000, 0.00000000, 'Karachi', 'some desc.', '400', 1, 6000.00, 0.00, NULL, NULL, NULL, '2026-04-19 19:13:18', NULL),
(2, 69, 'http://localhost:3000/uploads\\temp\\photo-bdf4f3c8-f2c4-44c9-bc68-c36ebb2d4c0b.png', 0.00000000, 0.00000000, '+uijvjjhjg', 'jbhjbbmnbm', '34', 1, 5000.00, 0.00, NULL, NULL, NULL, '2026-04-19 19:17:30', NULL),
(3, 69, 'http://localhost:3000/uploads\\temp\\photo-151b30fc-c59a-437e-b058-3b526a4c8583.png', 0.00000000, 0.00000000, 'location', 'my garbage uploaded', '56', 1, 569000.00, 0.00, NULL, NULL, NULL, '2026-04-22 13:07:26', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `id` bigint(20) NOT NULL,
  `region_name` varchar(191) NOT NULL,
  `region_type` varchar(50) NOT NULL,
  `parent_region_id` bigint(20) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `service_available` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reward_tiers`
--

CREATE TABLE `reward_tiers` (
  `id` bigint(20) NOT NULL,
  `tier_name` varchar(100) NOT NULL,
  `min_points` int(11) NOT NULL,
  `max_points` int(11) DEFAULT NULL,
  `benefits_description` text NOT NULL,
  `priority_scheduling` tinyint(1) DEFAULT 0,
  `discount_percentage` decimal(3,2) DEFAULT NULL,
  `badge_name` varchar(100) DEFAULT NULL,
  `badge_image_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_history`
--

CREATE TABLE `service_history` (
  `id` bigint(20) NOT NULL,
  `pickup_confirmation_id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `branch_id` bigint(20) NOT NULL,
  `driver_id` bigint(20) NOT NULL,
  `pickup_date` date NOT NULL,
  `pickup_time` time NOT NULL,
  `waste_category_id` bigint(20) NOT NULL,
  `weight_kg` decimal(10,2) NOT NULL,
  `location_address` text NOT NULL,
  `driver_rating` int(11) DEFAULT NULL,
  `industry_rating` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `collected_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `three_bin_reports`
--

CREATE TABLE `three_bin_reports` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `pickup_schedule_id` bigint(20) NOT NULL,
  `recyclables_kg` decimal(6,2) NOT NULL,
  `organic_kg` decimal(6,2) NOT NULL,
  `non_usable_kg` decimal(6,2) NOT NULL,
  `total_kg` decimal(6,2) NOT NULL,
  `separation_quality_rating` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `reported_at` datetime DEFAULT current_timestamp(),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tutorial_slider`
--

CREATE TABLE `tutorial_slider` (
  `id` bigint(20) NOT NULL,
  `video_id` bigint(20) NOT NULL,
  `position` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutorial_slider`
--

INSERT INTO `tutorial_slider` (`id`, `video_id`, `position`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(2, 4, 2, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(3, 7, 3, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(4, 10, 4, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(5, 13, 5, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(6, 16, 6, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(7, 20, 7, 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57');

-- --------------------------------------------------------

--
-- Table structure for table `tutorial_topics`
--

CREATE TABLE `tutorial_topics` (
  `id` bigint(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutorial_topics`
--

INSERT INTO `tutorial_topics` (`id`, `title`, `slug`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Smart Waste Technology', 'smart-waste-technology', 'Learn the fundamentals of proper waste segregation for effective recycling and disposal', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(2, 'Recycling Processes', 'recycling-processes', 'Understanding how different materials are recycled and processed', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(3, 'Hazardous Waste Management', 'hazardous-waste-management', 'Safe handling and disposal of hazardous materials', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(4, 'Composting Techniques', 'composting-techniques', 'Learn various composting methods for organic waste', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(5, 'E-Waste Management', 'e-waste-management', 'Proper disposal and recycling of electronic waste', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(6, 'Non-usable', 'Non-usable', 'Waste management strategies for industries', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(7, 'Organic', 'Organic', 'Methods to reduce and properly manage plastic waste', '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(8, 'Recyclables', 'Recyclables', 'Modern technology solutions for waste management', '2025-11-11 11:33:57', '2025-11-11 11:33:57');

-- --------------------------------------------------------

--
-- Table structure for table `tutorial_videos`
--

CREATE TABLE `tutorial_videos` (
  `id` bigint(20) NOT NULL,
  `topic_id` bigint(20) NOT NULL,
  `title` varchar(255) NOT NULL,
  `youtube_link` varchar(500) NOT NULL,
  `duration` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tutorial_videos`
--

INSERT INTO `tutorial_videos` (`id`, `topic_id`, `title`, `youtube_link`, `duration`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Introduction to Waste Segregation', 'https://vjs.zencdn.net/v/oceans.mp4', '10:25', 'Learn the basics of separating dry, wet, and hazardous waste', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(2, 1, 'Color Coding for Waste Bins', 'https://vjs.zencdn.net/v/oceans.mp4', '8:15', 'Understanding the color coding system for different waste types', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(3, 1, 'Common Segregation Mistakes', 'https://vjs.zencdn.net/v/oceans.mp4', '12:40', 'Avoid these common mistakes in waste segregation', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(4, 2, 'Plastic Recycling Journey', 'https://vjs.zencdn.net/v/oceans.mp4', '15:30', 'Follow the complete recycling process of plastic materials', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(5, 2, 'Paper Recycling Technology', 'https://vjs.zencdn.net/v/oceans.mp4', '11:20', 'Modern techniques in paper and cardboard recycling', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(6, 2, 'Glass and Metal Recycling', 'https://vjs.zencdn.net/v/oceans.mp4', '9:45', 'How glass and metal products are recycled and reused', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(7, 3, 'Identifying Hazardous Waste', 'https://vjs.zencdn.net/v/oceans.mp4', '14:10', 'Learn to identify common hazardous household items', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(8, 3, 'Safe Disposal Methods', 'https://vjs.zencdn.net/v/oceans.mp4', '16:25', 'Proper disposal techniques for hazardous materials', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(9, 3, 'Chemical Waste Handling', 'https://vjs.zencdn.net/v/oceans.mp4', '18:30', 'Industrial chemical waste management protocols', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(10, 4, 'Home Composting Basics', 'https://vjs.zencdn.net/v/oceans.mp4', '13:15', 'Start composting at home with simple methods', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(11, 4, 'Vermicomposting Guide', 'https://vjs.zencdn.net/v/oceans.mp4', '20:05', 'Using worms for efficient composting', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(12, 4, 'Large Scale Composting', 'https://vjs.zencdn.net/v/oceans.mp4', '22:40', 'Industrial composting techniques and facilities', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(13, 5, 'E-Waste Dangers and Solutions', 'https://vjs.zencdn.net/v/oceans.mp4', '17:50', 'Understanding the environmental impact of e-waste', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(14, 5, 'Proper E-Waste Disposal', 'https://vjs.zencdn.net/v/oceans.mp4', '11:35', 'How to safely dispose of electronic devices', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(15, 5, 'E-Waste Recycling Process', 'https://vjs.zencdn.net/v/oceans.mp4', '19:20', 'Inside an e-waste recycling facility', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(16, 6, 'Zero Waste Manufacturing', 'https://vjs.zencdn.net/v/oceans.mp4', '25:20', 'Strategies for waste reduction in manufacturingStrategies for waste reduction in manufacturingStrategies for waste reduction in manufacturingStrategies for waste reduction in manufacturingStrategies for waste reduction in manufacturingStrategies for waste reduction in manufacturing\n', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(17, 6, 'Industrial Recycling Systems', 'https://vjs.zencdn.net/v/oceans.mp4', '21:30', 'Setting up efficient recycling systems in industries', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(18, 7, 'Plastic Free Living', 'https://vjs.zencdn.net/v/oceans.mp4', '14:45', 'Practical tips to reduce plastic usage', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(19, 7, 'Plastic Recycling Innovations', 'https://vjs.zencdn.net/v/oceans.mp4', '16:55', 'New technologies in plastic waste management', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(20, 8, 'IoT in Waste Management', 'https://vjs.zencdn.net/v/oceans.mp4', '23:10', 'How Internet of Things is revolutionizing waste collection', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(21, 8, 'Smart Bin Technology', 'https://vjs.zencdn.net/v/oceans.mp4', '12:25', 'Advanced sensors and monitoring in waste bins', 1, '2025-11-11 11:33:57', '2025-11-11 11:33:57'),
(22, 7, 'r rtegertbeberg ef  we wef', 'https://vjs.zencdn.net/v/oceans.mp4', '20:24', ' eef f e fv ewfrvf cwe c we cewcv ew c 3erf e rf e2c er c2 3 v32 4rf 4 f23rf 23r 23', 1, '2026-01-15 20:11:34', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `types`
--

CREATE TABLE `types` (
  `id` bigint(20) NOT NULL,
  `type_name` varchar(191) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `group_id` bigint(20) DEFAULT NULL,
  `is_inactive` bit(1) DEFAULT b'0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `types`
--

INSERT INTO `types` (`id`, `type_name`, `created_at`, `updated_at`, `group_id`, `is_inactive`) VALUES
(1, 'industry', '2025-11-11 11:33:57', '2025-11-11 11:33:57', 2, b'0'),
(2, 'driver', '2025-11-11 11:33:57', '2025-11-11 11:33:57', 2, b'0'),
(3, 'citizen', '2025-11-11 11:33:57', '2025-11-11 11:33:57', 2, b'0'),
(4, 'admin', '2025-11-11 11:33:57', '2025-11-11 11:33:57', NULL, b'0'),
(5, 'otp_registration', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(6, 'otp_password_reset', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(7, 'otp_email_verification', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(8, 'otp_login_verification', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(9, 'otp_account_recovery', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(10, 'otp_status_pending', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(11, 'otp_status_verified', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(12, 'otp_status_expired', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(13, 'otp_status_failed', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(14, 'otp_status_cancelled', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(15, 'email_otp', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(16, 'email_welcome', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(17, 'email_password_reset', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(18, 'email_notification', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(19, 'email_newsletter', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(20, 'email_account_alert', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(21, 'email_status_pending', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(22, 'email_status_sent', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(23, 'email_status_delivered', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(24, 'email_status_opened', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(25, 'email_status_failed', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(26, 'email_status_bounced', '2025-11-21 11:30:17', '2025-11-21 11:30:17', NULL, b'0'),
(27, 'Industrial', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(28, 'Commercial', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(29, 'Residential', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(30, 'Waste Service Provider', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(31, 'Government & Municipal', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(32, 'Technology Provider', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 1, b'0'),
(33, 'Manufacturing Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(34, 'Chemical Industry', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(35, 'Pharmaceutical Company', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(36, 'Textile Mill', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(37, 'Food Processing Unit', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(38, 'Automotive Factory', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(39, 'Electronics Manufacturer', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(40, 'Metal Processing Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(41, 'Plastic Manufacturing', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(42, 'Paper Mill', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(43, 'Cement Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(44, 'Power Generation Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(45, 'Oil Refinery', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(46, 'Petrochemical Complex', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(47, 'Shopping Mall', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(48, 'Office Building', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(49, 'Hotel & Hospitality', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(50, 'Restaurant & Food Court', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(51, 'Retail Store', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(52, 'Supermarket/Hypermarket', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(53, 'Warehouse & Logistics', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(54, 'Educational Institution', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(55, 'Hospital & Healthcare', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(56, 'Bank & Financial Institution', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(57, 'Entertainment Complex', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(58, 'Airport & Transportation Hub', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(59, 'Residential Society', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(60, 'Apartment Complex', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(61, 'Gated Community', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(62, 'Housing Society', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(63, 'Township', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(64, 'Condominium', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(65, 'Co-operative Housing', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(66, 'Waste Collection Service', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(67, 'Recycling Facility', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(68, 'Composting Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(69, 'Waste-to-Energy Plant', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(70, 'Landfill Operation', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(71, 'Hazardous Waste Treatment', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(72, 'E-waste Recycling', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(73, 'Plastic Recycling', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(74, 'Metal Scrap Processing', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(75, 'Biomedical Waste Treatment', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(76, 'Construction Waste Management', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(77, 'Waste Transportation Service', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(78, 'Waste Audit & Consulting', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(79, 'Municipal Corporation', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(80, 'Urban Local Body', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(81, 'Public Works Department', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(82, 'Environmental Department', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(83, 'Sanitation Department', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(84, 'Water Supply Board', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(85, 'Development Authority', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(86, 'Waste Management Software', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(87, 'IoT Sensor Manufacturer', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(88, 'Analytics Platform', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(89, 'Mobile App Developer', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 3, b'0'),
(90, 'Biodegradable Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(91, 'Non-Biodegradable Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(92, 'Recyclable Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(93, 'Hazardous Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(94, 'Inert Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(95, 'Food Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(96, 'Garden Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(97, 'Agricultural Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(98, 'Animal Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(99, 'Wood Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(100, 'Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(101, 'Paper & Cardboard', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(102, 'Glass', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(103, 'Metal', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(104, 'Textiles', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(105, 'PET Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(106, 'HDPE Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(107, 'PVC Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(108, 'LDPE Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(109, 'PP Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(110, 'PS Plastic', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(111, 'Electronic Waste (E-Waste)', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(112, 'Batteries', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(113, 'Fluorescent Lamps', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(114, 'Paints & Solvents', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(115, 'Chemicals', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(116, 'Pesticides', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(117, 'Medical Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(118, 'Asbestos', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(119, 'Concrete & Bricks', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(120, 'Construction Debris', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(121, 'Gypsum Board', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(122, 'Roofing Materials', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(123, 'Insulation Materials', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(124, 'Sludge', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(125, 'Ash', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(126, 'Catalysts', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(127, 'Filter Cake', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(128, 'Spent Solvents', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(129, 'Used Oil', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(130, 'Tires', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(131, 'Marine Debris', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(132, 'Mixed Municipal Solid Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(133, 'Bulky Waste', '2025-11-11 06:33:57', '2025-11-11 06:33:57', 4, b'0'),
(134, 'order_pending', '2025-12-12 11:33:57', NULL, 5, b'0'),
(135, 'order_confirmed', '2025-12-12 11:33:57', NULL, 5, b'0'),
(136, 'order_scheduled', '2025-12-12 11:33:57', NULL, 5, b'0'),
(137, 'order_processing', '2025-12-12 11:33:57', NULL, 5, b'0'),
(138, 'order_shiped', '2025-12-12 11:33:57', NULL, 5, b'0'),
(139, 'order_delivered', '2025-12-12 11:33:57', NULL, 5, b'0'),
(140, 'order_completed', '2025-12-12 11:33:57', NULL, 5, b'0'),
(141, 'order_cancelled', '2025-12-12 11:33:57', NULL, 5, b'0'),
(142, 'order_failed', '2025-12-12 11:33:57', NULL, 5, b'0'),
(143, 'order_on_hold', '2025-12-12 11:33:57', NULL, 5, b'0'),
(144, 'order_rescheduled', '2025-12-12 11:33:57', NULL, 5, b'0'),
(145, 'order_refunded', '2025-12-12 11:33:57', NULL, 5, b'0'),
(146, 'payment_pending', '2025-12-12 11:33:57', NULL, 6, b'0'),
(147, 'payment_initiated', '2025-12-12 11:33:57', NULL, 6, b'0'),
(148, 'payment_processing', '2025-12-12 11:33:57', NULL, 6, b'0'),
(149, 'payment_paid', '2025-12-12 11:33:57', NULL, 6, b'0'),
(150, 'payment_partial_paid', '2025-12-12 11:33:57', NULL, 6, b'0'),
(151, 'payment_failed', '2025-12-12 11:33:57', NULL, 6, b'0'),
(152, 'payment_cancelled', '2025-12-12 11:33:57', NULL, 6, b'1'),
(153, 'payment_refunded', '2025-12-12 11:33:57', NULL, 6, b'1'),
(154, 'payment_chargeback', '2025-12-12 11:33:57', NULL, 6, b'1'),
(155, 'method_cash', '2025-12-12 11:33:57', NULL, 7, b'1'),
(156, 'method_cod', '2025-12-12 11:33:57', NULL, 7, b'0'),
(157, 'method_credit_card', '2025-12-12 11:33:57', NULL, 7, b'1'),
(158, 'method_debit_card', '2025-12-12 11:33:57', NULL, 7, b'1'),
(159, 'method_bank_transfer', '2025-12-12 11:33:57', NULL, 7, b'1'),
(160, 'method_mobile_wallet', '2025-12-12 11:33:57', NULL, 7, b'1'),
(161, 'method_online_gateway', '2025-12-12 11:33:57', NULL, 7, b'1'),
(162, 'method_cheque', '2025-12-12 11:33:57', NULL, 7, b'1'),
(163, 'method_pos', '2025-12-12 11:33:57', NULL, 7, b'1'),
(164, 'method_crypto', '2025-12-12 11:33:57', NULL, 7, b'1'),
(165, 'general', '2025-12-12 11:33:57', NULL, 8, b'0'),
(166, 'bid_pending', '2025-12-12 11:33:57', NULL, 9, b'0'),
(167, 'bid_accepted', '2025-12-12 11:33:57', NULL, 9, b'0'),
(168, 'bid_rejected', '2025-12-12 11:33:57', NULL, 9, b'0'),
(169, 'bid_expired', '2025-12-12 11:33:57', NULL, 9, b'0'),
(170, 'report_status_reported', '2025-12-12 11:33:57', NULL, 10, b'0'),
(171, 'report_status_under_review', '2025-12-12 11:33:57', NULL, 10, b'0'),
(172, 'report_status_funded', '2025-12-12 11:33:57', NULL, 10, b'0'),
(173, 'report_status_scheduled', '2025-12-12 11:33:57', NULL, 10, b'0'),
(174, 'report_status_cleaned', '2025-12-12 11:33:57', NULL, 10, b'0'),
(175, 'notification_types_alert', '2025-12-12 11:33:57', NULL, 11, b'0'),
(176, 'notification_types_update', '2025-12-12 11:33:57', NULL, 11, b'0'),
(177, 'notification_types_announcement', '2025-12-12 11:33:57', NULL, 11, b'0'),
(178, 'notification_types_reminder', '2025-12-12 11:33:57', NULL, 11, b'0'),
(179, 'pickup_statuses_scheduled', '2025-12-12 11:33:57', NULL, 12, b'0'),
(180, 'pickup_statuses_in_progress', '2025-12-12 11:33:57', NULL, 12, b'0'),
(181, 'pickup_statuses_completed', '2025-12-12 11:33:57', NULL, 12, b'0'),
(182, 'pickup_statuses_cancelled', '2025-12-12 11:33:57', NULL, 12, b'0'),
(183, 'priority_levels_low', '2025-12-12 11:33:57', NULL, 13, b'0'),
(184, 'priority_levels_medium', '2025-12-12 11:33:57', NULL, 13, b'0'),
(185, 'priority_levels_high', '2025-12-12 11:33:57', NULL, 13, b'0'),
(186, 'priority_levels_urgent', '2025-12-12 11:33:57', NULL, 13, b'0'),
(187, 'message_types_official', '2025-12-12 11:33:57', NULL, 14, b'0'),
(188, 'message_types_warning', '2025-12-12 11:33:57', NULL, 14, b'0'),
(189, 'message_types_update', '2025-12-12 11:33:57', NULL, 14, b'0'),
(190, 'message_types_announcement', '2025-12-12 11:33:57', NULL, 14, b'0'),
(191, 'rating_categories_waste_separation', '2025-12-12 11:33:57', NULL, 15, b'0'),
(192, 'rating_categories_cooperation', '2025-12-12 11:33:57', NULL, 15, b'0'),
(193, 'rating_categories_facility', '2025-12-12 11:33:57', NULL, 15, b'0'),
(194, 'promotion_types_percentage_discount', '2025-12-12 11:33:57', NULL, 16, b'0'),
(195, 'promotion_types_fixed_discount', '2025-12-12 11:33:57', NULL, 16, b'0'),
(196, 'promotion_types_free_shipping', '2025-12-12 11:33:57', NULL, 16, b'0'),
(197, 'verification_statuses_verified', '2025-12-12 11:33:57', NULL, 17, b'0'),
(198, 'verification_statuses_pending', '2025-12-12 11:33:57', NULL, 17, b'0'),
(199, 'verification_statuses_failed', '2025-12-12 11:33:57', NULL, 17, b'0'),
(200, 'issue_types_bin_empty', '2025-12-12 11:33:57', NULL, 18, b'0'),
(201, 'issue_types_access_blocked', '2025-12-12 11:33:57', NULL, 18, b'0'),
(202, 'issue_types_wet_waste', '2025-12-12 11:33:57', NULL, 18, b'0'),
(203, 'issue_types_damaged_container', '2025-12-12 11:33:57', NULL, 18, b'0');

-- --------------------------------------------------------

--
-- Table structure for table `type_groups`
--

CREATE TABLE `type_groups` (
  `id` bigint(20) NOT NULL,
  `type_group_name` varchar(191) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `type_groups`
--

INSERT INTO `type_groups` (`id`, `type_group_name`, `created_at`, `updated_at`) VALUES
(1, 'company_registration', '2025-11-27 08:20:27', NULL),
(2, 'user_registration', '2025-11-27 08:24:00', NULL),
(3, 'business_types', '2025-11-27 08:51:07', NULL),
(4, 'waste_types', '2025-11-27 11:02:47', NULL),
(5, 'order_statuses', '2025-12-15 10:44:34', NULL),
(6, 'payment_statuses', '2025-12-15 10:44:34', NULL),
(7, 'payment_method', '2025-12-15 10:44:34', NULL),
(8, 'bid_type', '2025-12-15 14:40:29', NULL),
(9, 'bid_statuses', '2025-12-15 14:40:29', NULL),
(10, 'report_statuses', '2025-12-15 14:40:29', NULL),
(11, 'notification_types', '2025-12-15 14:40:29', NULL),
(12, 'pickup_statuses', '2025-12-15 14:40:29', NULL),
(13, 'priority_levels', '2025-12-15 14:40:29', NULL),
(14, 'message_types', '2025-12-15 14:40:29', NULL),
(15, 'rating_categories', '2025-12-15 14:40:29', NULL),
(16, 'promotion_types', '2025-12-15 14:40:29', NULL),
(17, 'verification_statuses', '2025-12-15 14:40:29', NULL),
(18, 'issue_types', '2025-12-15 14:40:29', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL,
  `full_name` varchar(191) NOT NULL,
  `email` varchar(191) NOT NULL,
  `email_verified_at` datetime DEFAULT NULL,
  `password` varchar(191) NOT NULL,
  `phone_number` varchar(191) NOT NULL,
  `user_type_id` bigint(20) NOT NULL,
  `designation_id` bigint(20) DEFAULT NULL,
  `active_status` tinyint(1) DEFAULT 1,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `email_verified_at`, `password`, `phone_number`, `user_type_id`, `designation_id`, `active_status`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'superadmin@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+92+1-555-010', 4, 1, 1, NULL, '2025-11-11 11:33:58', '2026-04-16 14:56:28'),
(2, 'System Administrator', 'admin@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0101', 4, 4, 1, NULL, '2025-11-11 11:33:59', '2025-11-11 11:33:59'),
(3, 'Operations Manager', 'operations@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0102', 4, 1, 1, NULL, '2025-11-11 11:33:59', '2025-11-11 11:33:59'),
(4, 'HR Admin', 'hradmin@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0103', 4, 2, 1, NULL, '2025-11-11 11:33:59', '2025-11-11 11:33:59'),
(5, 'Support Admin', 'supportadmin@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0104', 4, 3, 1, NULL, '2025-11-11 11:33:59', '2025-11-11 11:33:59'),
(6, 'John Smith', 'ecotechindustries@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0200', 1, 2, 1, NULL, '2025-11-11 11:33:59', '2025-11-11 11:33:59'),
(7, 'Sarah Johnson', 'greensolutionscorp@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0201', 1, 6, 1, NULL, '2025-11-11 11:34:00', '2025-11-11 11:34:00'),
(8, 'Michael Williams', 'sustainablematerialsltd@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0202', 1, 5, 1, NULL, '2025-11-11 11:34:00', '2025-11-11 11:34:00'),
(9, 'Emily Brown', 'cleanenergyinc@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0203', 1, 7, 1, NULL, '2025-11-11 11:34:00', '2025-11-11 11:34:00'),
(10, 'David Jones', 'ecofriendlymanufacturing@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0204', 1, 2, 1, NULL, '2025-11-11 11:34:00', '2025-11-11 11:34:00'),
(11, 'Lisa Miller', 'greentechsolutions@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0205', 1, 2, 1, NULL, '2025-11-11 11:34:00', '2025-11-11 11:34:00'),
(12, 'Robert Davis', 'environmentalservicesco@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0206', 1, 7, 1, NULL, '2025-11-11 11:34:01', '2025-11-11 11:34:01'),
(13, 'Jennifer Garcia', 'wastemanagementltd@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0207', 1, 3, 1, NULL, '2025-11-11 11:34:01', '2025-11-11 11:34:01'),
(14, 'William Rodriguez', 'recyclingtechnologies@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0208', 1, 4, 1, NULL, '2025-11-11 11:34:01', '2025-11-11 11:34:01'),
(15, 'Maria Wilson', 'bioenergycorp@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0209', 1, 7, 1, NULL, '2025-11-11 11:34:01', '2025-11-11 11:34:01'),
(16, 'James Martinez', 'ecomanufacturinginc@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0210', 1, 5, 1, NULL, '2025-11-11 11:34:01', '2025-11-11 11:34:01'),
(17, 'Susan Anderson', 'sustainablesolutionsllc@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0211', 1, 4, 1, NULL, '2025-11-11 11:34:02', '2025-11-11 11:34:02'),
(18, 'Richard Taylor', 'greenindustries@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0212', 1, 3, 1, NULL, '2025-11-11 11:34:02', '2025-11-11 11:34:02'),
(19, 'Karen Moore', 'cleantechmanufacturing@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0213', 1, 1, 1, NULL, '2025-11-11 11:34:02', '2025-11-11 11:34:02'),
(20, 'Thomas Jackson', 'ecosystemsltd@industry.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0214', 1, 5, 1, NULL, '2025-11-11 11:34:02', '2025-11-11 11:34:02'),
(21, 'Mike Thompson', 'driver1@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0300', 2, 7, 1, NULL, '2025-11-11 11:34:02', '2025-11-11 11:34:02'),
(22, 'Chris Martinez', 'driver2@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0301', 2, 7, 1, NULL, '2025-11-11 11:34:03', '2025-11-11 11:34:03'),
(23, 'Alex Clark', 'driver3@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0302', 2, 7, 1, NULL, '2025-11-11 11:34:03', '2025-11-11 11:34:03'),
(24, 'Jordan Lewis', 'driver4@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0303', 2, 7, 1, NULL, '2025-11-11 11:34:03', '2025-11-11 11:34:03'),
(25, 'Taylor Lee', 'driver5@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0304', 2, 7, 1, NULL, '2025-11-11 11:34:03', '2025-11-11 11:34:03'),
(26, 'Casey Walker', 'driver6@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0305', 2, 7, 1, NULL, '2025-11-11 11:34:03', '2025-11-11 11:34:03'),
(27, 'Jamie Hall', 'driver7@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0306', 2, 7, 1, NULL, '2025-11-11 11:34:04', '2025-11-11 11:34:04'),
(28, 'Danny Allen', 'driver8@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0307', 2, 7, 1, NULL, '2025-11-11 11:34:04', '2025-11-11 11:34:04'),
(29, 'Sam Young', 'driver9@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0308', 2, 7, 1, NULL, '2025-11-11 11:34:04', '2025-11-11 11:34:04'),
(30, 'Robin King', 'driver10@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0309', 2, 7, 1, NULL, '2025-11-11 11:34:04', '2025-11-11 11:34:04'),
(31, 'Pat Wright', 'driver11@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0310', 2, 7, 1, NULL, '2025-11-11 11:34:04', '2025-11-11 11:34:04'),
(32, 'Misbah\nDriver', 'misbahmaqboolofficial247@gmail.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0311', 2, 7, 1, NULL, '2025-11-11 11:34:05', '2025-11-11 11:34:05'),
(33, 'Morgan Adams', 'driver13@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0312', 2, 7, 1, NULL, '2025-11-11 11:34:05', '2025-11-11 11:34:05'),
(34, 'Riley Baker', 'driver14@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0313', 2, 7, 1, NULL, '2025-11-11 11:34:05', '2025-11-11 11:34:05'),
(35, 'Drew Carter', 'driver15@wastemanagement.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0314', 2, 7, 1, NULL, '2025-11-11 11:34:05', '2025-11-11 11:34:05'),
(36, 'Emma Gonzalez', 'citizen1@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0400', 3, NULL, 1, NULL, '2025-11-11 11:34:05', '2025-11-11 11:34:05'),
(37, 'Noah Harris', 'citizen2@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0401', 3, NULL, 1, NULL, '2025-11-11 11:34:06', '2025-11-11 11:34:06'),
(38, 'Olivia Nelson', 'citizen3@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0402', 3, NULL, 1, NULL, '2025-11-11 11:34:06', '2025-11-11 11:34:06'),
(39, 'Liam Robinson', 'citizen4@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0403', 3, NULL, 1, NULL, '2025-11-11 11:34:06', '2025-11-11 11:34:06'),
(40, 'Ava White', 'citizen5@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0404', 3, NULL, 1, NULL, '2025-11-11 11:34:06', '2025-11-11 11:34:06'),
(41, 'Lucas Clark', 'citizen6@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0405', 3, NULL, 1, NULL, '2025-11-11 11:34:06', '2025-11-11 11:34:06'),
(42, 'Sophia Lewis', 'citizen7@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0406', 3, NULL, 1, NULL, '2025-11-11 11:34:07', '2025-11-11 11:34:07'),
(43, 'Mason Walker', 'citizen8@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0407', 3, NULL, 1, NULL, '2025-11-11 11:34:07', '2025-11-11 11:34:07'),
(44, 'Isabella Hall', 'citizen9@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0408', 3, NULL, 1, NULL, '2025-11-11 11:34:07', '2025-11-11 11:34:07'),
(45, 'Ethan Allen', 'citizen10@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0409', 3, NULL, 1, NULL, '2025-11-11 11:34:07', '2025-11-11 11:34:07'),
(46, 'Mia Young', 'citizen11@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0410', 3, NULL, 1, NULL, '2025-11-11 11:34:07', '2025-11-11 11:34:07'),
(47, 'Logan Hernandez', 'citizen12@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0411', 3, NULL, 1, NULL, '2025-11-11 11:34:08', '2025-11-11 11:34:08'),
(48, 'Amelia King', 'citizen13@community.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+1-555-0412', 3, NULL, 1, NULL, '2025-11-11 11:34:08', '2025-11-11 11:34:08'),
(67, 'Misbah Industry', 'misbahmaqbool154@gmail.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+923308060604', 1, 1, 1, NULL, '2025-11-22 12:46:46', '2025-11-22 12:46:46'),
(69, 'Misbah Citizen', 'misbahmaqbool123official@gmail.com', '2025-11-27 11:06:06', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+920330806060', 3, NULL, 1, NULL, '2025-11-25 21:48:23', '2025-11-25 21:48:23'),
(70, 'ab12345', 'misbahmaqboolofficial@gmail.com', '2025-12-03 14:09:46', '$2b$12$/c0/T09AcjJbWCCia/IkOuQPI3/iUDROwCVtNBl.p5hYWdaRLcUk2', '+922834782431', 4, NULL, 1, NULL, '2025-12-03 14:04:41', '2026-05-05 14:36:49'),
(71, 'misbah maqbool', 'misbahmaqbool254@gmail.com', '2026-01-21 13:48:36', '$2b$12$3ZQUWDYhi04VXYHpXYn9p.zNlaG09Sf3QVE50jcxvX/l0vDxvUKrS', '+923093199935', 3, NULL, 1, NULL, '2026-01-21 13:47:15', '2026-01-21 13:47:15'),
(74, 'Test Driver ', 'mydriver@test.com', NULL, '$2b$12$GaZsMmUYw9YCO93.n1Hz6.CQOizJHzcLbnyN.0nkFOgy.Udj6LFAu', '+1234567890', 2, NULL, 1, NULL, '2026-01-21 20:43:05', '2026-01-21 20:43:05'),
(75, 'ali', 'ali@gmail.com', NULL, '$2b$12$O1R37ujlw4DG.p4PV2rTmu2uX9FtJ8QgTQsR3YHHbVaZOc2JT84Se', '+923093199935', 2, NULL, 1, NULL, '2026-01-21 20:47:07', '2026-01-21 20:47:07');

-- --------------------------------------------------------

--
-- Table structure for table `user_tutorial_progress`
--

CREATE TABLE `user_tutorial_progress` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `tutorial_video_id` bigint(20) NOT NULL,
  `watched_duration_seconds` int(11) DEFAULT NULL,
  `total_duration_seconds` int(11) DEFAULT NULL,
  `completion_percentage` int(11) DEFAULT NULL,
  `completed` tinyint(1) DEFAULT 0,
  `completed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `vehicle_locations`
--

CREATE TABLE `vehicle_locations` (
  `id` bigint(20) NOT NULL,
  `driver_id` bigint(20) NOT NULL,
  `vehicle_id` bigint(20) DEFAULT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `speed` decimal(5,2) DEFAULT NULL,
  `heading` decimal(5,2) DEFAULT NULL,
  `accuracy` decimal(5,2) DEFAULT NULL,
  `pickup_schedule_id` bigint(20) DEFAULT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `recorded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `waste_categories`
--

CREATE TABLE `waste_categories` (
  `id` bigint(20) NOT NULL,
  `category_name` varchar(191) NOT NULL,
  `description` text DEFAULT NULL,
  `color_code` varchar(20) DEFAULT NULL,
  `icon_url` varchar(500) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `waste_categories`
--

INSERT INTO `waste_categories` (`id`, `category_name`, `description`, `color_code`, `icon_url`, `created_at`, `updated_at`) VALUES
(1, 'Plastic Waste', 'Plastic bottles, containers, and packaging', '#1abc9c', 'icons/plastic.png', '2026-01-15 13:27:13', NULL),
(2, 'Paper Waste', 'Paper, newspapers, magazines, and cartons', '#3498db', 'icons/paper.png', '2026-01-15 13:27:13', NULL),
(3, 'Glass Waste', 'Glass bottles and jars', '#9b59b6', 'icons/glass.png', '2026-01-15 13:27:13', NULL),
(4, 'Metal Waste', 'Aluminum, steel cans, and metal scraps', '#95a5a6', 'icons/metal.png', '2026-01-15 13:27:13', NULL),
(5, 'Organic Waste', 'Food scraps and biodegradable waste', '#27ae60', 'icons/organic.png', '2026-01-15 13:27:13', NULL),
(6, 'Electronic Waste', 'Discarded electronic devices and components', '#e74c3c', 'icons/ewaste.png', '2026-01-15 13:27:13', NULL),
(7, 'Battery Waste', 'Used household and industrial batteries', '#f39c12', 'icons/battery.png', '2026-01-15 13:27:13', NULL),
(8, 'Medical Waste', 'Hospital and clinical waste', '#c0392b', 'icons/medical.png', '2026-01-15 13:27:13', NULL),
(9, 'Hazardous Waste', 'Chemicals, paints, and toxic materials', '#8e44ad', 'icons/hazardous.png', '2026-01-15 13:27:13', NULL),
(10, 'Construction Debris', 'Bricks, concrete, and construction materials', '#7f8c8d', 'icons/construction.png', '2026-01-15 13:27:13', NULL),
(11, 'Textile Waste', 'Old clothes and fabric materials', '#d35400', 'icons/textile.png', '2026-01-15 13:27:13', NULL),
(12, 'Wood Waste', 'Wood scraps and furniture waste', '#a0522d', 'icons/wood.png', '2026-01-15 13:27:13', NULL),
(13, 'Rubber Waste', 'Tires and rubber products', '#2c3e50', 'icons/rubber.png', '2026-01-15 13:27:13', NULL),
(14, 'Packaging Waste', 'Boxes, wrappers, and packaging materials', '#16a085', 'icons/packaging.png', '2026-01-15 13:27:13', NULL),
(15, 'Food Waste', 'Expired and leftover food items', '#2ecc71', 'icons/food.png', '2026-01-15 13:27:13', NULL),
(16, 'Garden Waste', 'Leaves, grass, and garden trimmings', '#6ab04c', 'icons/garden.png', '2026-01-15 13:27:13', NULL),
(17, 'Oil Waste', 'Used cooking and industrial oils', '#34495e', 'icons/oil.png', '2026-01-15 13:27:13', NULL),
(18, 'Chemical Waste', 'Laboratory and industrial chemicals', '#e84393', 'icons/chemical.png', '2026-01-15 13:27:13', NULL),
(19, 'Radioactive Waste', 'Radioactive materials and residues', '#fdcb6e', 'icons/radioactive.png', '2026-01-15 13:27:13', NULL),
(20, 'Leather Waste', 'Leather scraps and rejected products', '#8d6e63', 'icons/leather.png', '2026-01-15 13:27:13', NULL),
(21, 'Ceramic Waste', 'Broken tiles and ceramics', '#b2bec3', 'icons/ceramic.png', '2026-01-15 13:27:13', NULL),
(22, 'Ash Waste', 'Coal and wood ash residues', '#636e72', 'icons/ash.png', '2026-01-15 13:27:13', NULL),
(23, 'Sanitary Waste', 'Diapers, sanitary pads, and hygiene products', '#ff7675', 'icons/sanitary.png', '2026-01-15 13:27:13', NULL),
(24, 'Agricultural Waste', 'Crop residues and farming waste', '#55efc4', 'icons/agriculture.png', '2026-01-15 13:27:13', NULL),
(25, 'Fishing Waste', 'Discarded nets and fishing gear', '#0984e3', 'icons/fishing.png', '2026-01-15 13:27:13', NULL),
(26, 'Slaughterhouse Waste', 'Animal by-products and organic residues', '#d63031', 'icons/slaughterhouse.png', '2026-01-15 13:27:13', NULL),
(27, 'Pharmaceutical Waste', 'Expired medicines and medical drugs', '#6c5ce7', 'icons/pharma.png', '2026-01-15 13:27:13', NULL),
(28, 'Ink & Toner Waste', 'Printer cartridges and toner waste', '#2d3436', 'icons/ink.png', '2026-01-15 13:27:13', NULL),
(29, 'Foam Waste', 'Styrofoam and foam packaging', '#74b9ff', 'icons/foam.png', '2026-01-15 13:27:13', NULL),
(30, 'Coconut Shell Waste', 'Discarded coconut shells', '#a29bfe', 'icons/coconut.png', '2026-01-15 13:27:13', NULL),
(31, 'Shellfish Waste', 'Shells from seafood processing', '#81ecec', 'icons/shellfish.png', '2026-01-15 13:27:13', NULL),
(32, 'Animal Manure', 'Livestock and poultry manure', '#7bed9f', 'icons/manure.png', '2026-01-15 13:27:13', NULL),
(33, 'Leather Chemical Waste', 'Chemical residues from leather processing', '#b71540', 'icons/leather_chem.png', '2026-01-15 13:27:13', NULL),
(34, 'Paint Waste', 'Leftover paints and varnishes', '#f368e0', 'icons/paint.png', '2026-01-15 13:27:13', NULL),
(35, 'Solvent Waste', 'Industrial and laboratory solvents', '#ff9f43', 'icons/solvent.png', '2026-01-15 13:27:13', NULL),
(36, 'Demolition Waste', 'Debris from demolition sites', '#576574', 'icons/demolition.png', '2026-01-15 13:27:13', NULL),
(37, 'Tyre Waste', 'Used and damaged vehicle tyres', '#222f3e', 'icons/tyre.png', '2026-01-15 13:27:13', NULL),
(38, 'Glass Fiber Waste', 'Fiberglass industrial waste', '#48dbfb', 'icons/fiberglass.png', '2026-01-15 13:27:13', NULL),
(39, 'Mining Waste', 'Tailings and mining residues', '#5f27cd', 'icons/mining.png', '2026-01-15 13:27:13', NULL),
(40, 'Mixed Municipal Waste', 'Unsegregated household waste', '#10ac84', 'icons/municipal.png', '2026-01-15 13:27:13', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `waste_reports`
--

CREATE TABLE `waste_reports` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `company_id` bigint(20) NOT NULL,
  `waste_category_id` bigint(20) NOT NULL,
  `weight_kg` decimal(10,2) NOT NULL,
  `report_date` date NOT NULL,
  `status_id` bigint(20) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `waste_reports`
--

INSERT INTO `waste_reports` (`id`, `user_id`, `company_id`, `waste_category_id`, `weight_kg`, `report_date`, `status_id`, `notes`, `created_at`, `updated_at`) VALUES
(1, 67, 1, 1, 250.00, '2024-01-10', 1, 'Monthly waste report', '2026-01-15 14:50:51', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `waste_tracking`
--

CREATE TABLE `waste_tracking` (
  `id` bigint(20) NOT NULL,
  `company_id` bigint(20) DEFAULT NULL,
  `pickup_schedule_id` bigint(20) DEFAULT NULL,
  `waste_category_id` bigint(20) NOT NULL,
  `weight_kg` decimal(10,2) NOT NULL,
  `co2_reduction_kg` decimal(10,2) NOT NULL,
  `methane_reduction_kg` decimal(10,2) NOT NULL,
  `water_saved_liters` decimal(10,2) NOT NULL,
  `recycled_into_product_id` bigint(20) DEFAULT NULL,
  `tracking_date` date NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bids`
--
ALTER TABLE `bids`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bids_index_24` (`company_id`),
  ADD KEY `bids_index_25` (`bid_status_id`),
  ADD KEY `bids_index_26` (`waste_category_id`),
  ADD KEY `bids_index_27` (`price_per_kg`,`bid_type_id`),
  ADD KEY `bid_type_id` (`bid_type_id`);

--
-- Indexes for table `blocked_industries`
--
ALTER TABLE `blocked_industries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_id` (`company_id`),
  ADD KEY `blocked_industries_index_55` (`company_id`),
  ADD KEY `blocked_industries_index_56` (`blocked_by_user_id`);

--
-- Indexes for table `branches`
--
ALTER TABLE `branches`
  ADD PRIMARY KEY (`id`),
  ADD KEY `branches_index_3` (`branch_name`),
  ADD KEY `company_id` (`company_id`);

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status_id` (`status_id`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cart_items_index_40` (`cart_id`,`product_id`),
  ADD KEY `cart_items_index_39` (`cart_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `ceo_messages`
--
ALTER TABLE `ceo_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ceo_messages_index_73` (`sender_user_id`),
  ADD KEY `ceo_messages_index_74` (`recipient_user_id`),
  ADD KEY `ceo_messages_index_75` (`recipient_company_id`),
  ADD KEY `ceo_messages_index_76` (`status_id`),
  ADD KEY `ceo_messages_index_77` (`sent_at`),
  ADD KEY `recipient_type_id` (`recipient_type_id`),
  ADD KEY `message_type_id` (`message_type_id`);

--
-- Indexes for table `companies`
--
ALTER TABLE `companies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `companies_index_2` (`company_name`),
  ADD KEY `company_type_id` (`company_type_id`),
  ADD KEY `business_type_id` (`business_type_id`);

--
-- Indexes for table `company_users`
--
ALTER TABLE `company_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_users_index_13` (`user_id`,`company_id`,`branch_id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `branch_id` (`branch_id`);

--
-- Indexes for table `designations`
--
ALTER TABLE `designations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `designation_name` (`designation_name`);

--
-- Indexes for table `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `vehicle_plate_number` (`vehicle_plate_number`),
  ADD UNIQUE KEY `driving_license_number` (`driving_license_number`),
  ADD KEY `drivers_index_12` (`vehicle_plate_number`);

--
-- Indexes for table `driver_tasks`
--
ALTER TABLE `driver_tasks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `driver_tasks_index_47` (`driver_id`),
  ADD KEY `driver_tasks_index_48` (`task_date`),
  ADD KEY `driver_tasks_index_49` (`task_status_id`),
  ADD KEY `driver_tasks_index_50` (`driver_id`,`task_date`,`route_order`),
  ADD KEY `pickup_schedule_id` (`pickup_schedule_id`);

--
-- Indexes for table `email_messages`
--
ALTER TABLE `email_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email_messages_index_14` (`email`),
  ADD KEY `email_messages_index_15` (`message_type_id`),
  ADD KEY `email_messages_index_16` (`status_id`),
  ADD KEY `email_messages_index_17` (`sent_at`),
  ADD KEY `email_messages_index_18` (`created_at`),
  ADD KEY `email_messages_index_19` (`user_id`);

--
-- Indexes for table `garbage_report_donations`
--
ALTER TABLE `garbage_report_donations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `garbage_report_donations_index_62` (`report_id`),
  ADD KEY `garbage_report_donations_index_63` (`donor_user_id`),
  ADD KEY `garbage_report_donations_index_64` (`status_id`);

--
-- Indexes for table `industry_priorities`
--
ALTER TABLE `industry_priorities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `company_id` (`company_id`),
  ADD KEY `last_updated_by_user_id` (`last_updated_by_user_id`);

--
-- Indexes for table `industry_ratings`
--
ALTER TABLE `industry_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `industry_ratings_index_54` (`company_id`,`rated_by_user_id`),
  ADD KEY `industry_ratings_index_51` (`company_id`),
  ADD KEY `industry_ratings_index_52` (`rated_by_user_id`),
  ADD KEY `industry_ratings_index_53` (`created_at`);

--
-- Indexes for table `industry_rewards`
--
ALTER TABLE `industry_rewards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `industry_rewards_index_86` (`company_id`),
  ADD KEY `industry_rewards_index_87` (`total_points`),
  ADD KEY `current_tier_id` (`current_tier_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_index_65` (`sender_user_id`),
  ADD KEY `notifications_index_66` (`recipient_user_id`),
  ADD KEY `notifications_index_67` (`notification_type_id`),
  ADD KEY `notifications_index_68` (`status_id`),
  ADD KEY `notifications_index_69` (`scheduled_at`),
  ADD KEY `recipient_type_id` (`recipient_type_id`),
  ADD KEY `priority_level_id` (`priority_level_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `orders_index_41` (`user_id`),
  ADD KEY `orders_index_42` (`order_status_id`),
  ADD KEY `orders_index_43` (`payment_status_id`),
  ADD KEY `orders_index_44` (`created_at`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `payment_method_id` (`payment_method_id`),
  ADD KEY `promotion_id` (`promotion_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_index_45` (`order_id`),
  ADD KEY `order_items_index_46` (`product_id`);

--
-- Indexes for table `otps`
--
ALTER TABLE `otps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `otps_index_5` (`email`),
  ADD KEY `otps_index_6` (`otp_code`),
  ADD KEY `otps_index_7` (`purpose_id`),
  ADD KEY `otps_index_8` (`status_id`),
  ADD KEY `otps_index_9` (`expires_at`),
  ADD KEY `otps_index_10` (`created_at`),
  ADD KEY `otps_index_11` (`user_id`);

--
-- Indexes for table `pickup_confirmations`
--
ALTER TABLE `pickup_confirmations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pickup_schedule_id` (`pickup_schedule_id`),
  ADD KEY `driver_id` (`driver_id`),
  ADD KEY `verification_status_id` (`verification_status_id`),
  ADD KEY `issue_reported_id` (`issue_reported_id`);

--
-- Indexes for table `pickup_schedules`
--
ALTER TABLE `pickup_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pickup_schedules_index_28` (`company_id`),
  ADD KEY `pickup_schedules_index_29` (`driver_id`),
  ADD KEY `pickup_schedules_index_30` (`scheduled_date`),
  ADD KEY `pickup_schedules_index_31` (`pickup_status_id`),
  ADD KEY `bid_id` (`bid_id`),
  ADD KEY `branch_id` (`branch_id`),
  ADD KEY `waste_type_id` (`waste_type_id`),
  ADD KEY `priority_level_id` (`priority_level_id`),
  ADD KEY `fk_pickup_schedules_user_id` (`user_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_code` (`product_code`),
  ADD KEY `products_index_36` (`category_id`),
  ADD KEY `products_index_37` (`status_id`),
  ADD KEY `products_index_38` (`product_code`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `promotion_code` (`promotion_code`),
  ADD KEY `discount_type_id` (`discount_type_id`),
  ADD KEY `status_id` (`status_id`);

--
-- Indexes for table `public_garbage_reports`
--
ALTER TABLE `public_garbage_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `public_garbage_reports_index_57` (`reported_by_user_id`),
  ADD KEY `public_garbage_reports_index_58` (`report_status_id`),
  ADD KEY `public_garbage_reports_index_59` (`latitude`),
  ADD KEY `public_garbage_reports_index_60` (`longitude`),
  ADD KEY `public_garbage_reports_index_61` (`created_at`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `region_name` (`region_name`),
  ADD KEY `parent_region_id` (`parent_region_id`);

--
-- Indexes for table `reward_tiers`
--
ALTER TABLE `reward_tiers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tier_name` (`tier_name`);

--
-- Indexes for table `service_history`
--
ALTER TABLE `service_history`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pickup_confirmation_id` (`pickup_confirmation_id`),
  ADD KEY `service_history_index_32` (`company_id`),
  ADD KEY `service_history_index_33` (`driver_id`),
  ADD KEY `service_history_index_34` (`pickup_date`),
  ADD KEY `service_history_index_35` (`waste_category_id`),
  ADD KEY `branch_id` (`branch_id`),
  ADD KEY `fk_service_collected_by` (`collected_by`);

--
-- Indexes for table `three_bin_reports`
--
ALTER TABLE `three_bin_reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `three_bin_reports_index_85` (`pickup_schedule_id`),
  ADD KEY `three_bin_reports_index_84` (`company_id`),
  ADD KEY `fk_three_bin_report_user_id` (`user_id`);

--
-- Indexes for table `tutorial_slider`
--
ALTER TABLE `tutorial_slider`
  ADD PRIMARY KEY (`id`),
  ADD KEY `tutorial_slider_index_4` (`video_id`);

--
-- Indexes for table `tutorial_topics`
--
ALTER TABLE `tutorial_topics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `tutorial_videos`
--
ALTER TABLE `tutorial_videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `topic_id` (`topic_id`);

--
-- Indexes for table `types`
--
ALTER TABLE `types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `type_name` (`type_name`),
  ADD KEY `group_id` (`group_id`);

--
-- Indexes for table `type_groups`
--
ALTER TABLE `type_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `type_group_name` (`type_group_name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `users_index_0` (`email`),
  ADD KEY `users_index_1` (`phone_number`),
  ADD KEY `user_type_id` (`user_type_id`),
  ADD KEY `designation_id` (`designation_id`);

--
-- Indexes for table `user_tutorial_progress`
--
ALTER TABLE `user_tutorial_progress`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_tutorial_progress_index_81` (`user_id`,`tutorial_video_id`),
  ADD KEY `user_tutorial_progress_index_82` (`user_id`),
  ADD KEY `user_tutorial_progress_index_83` (`completed`),
  ADD KEY `tutorial_video_id` (`tutorial_video_id`);

--
-- Indexes for table `vehicle_locations`
--
ALTER TABLE `vehicle_locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vehicle_locations_index_70` (`driver_id`),
  ADD KEY `vehicle_locations_index_71` (`recorded_at`),
  ADD KEY `vehicle_locations_index_72` (`driver_id`,`recorded_at`),
  ADD KEY `vehicle_id` (`vehicle_id`),
  ADD KEY `pickup_schedule_id` (`pickup_schedule_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `waste_categories`
--
ALTER TABLE `waste_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_name` (`category_name`);

--
-- Indexes for table `waste_reports`
--
ALTER TABLE `waste_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `waste_reports_index_20` (`user_id`),
  ADD KEY `waste_reports_index_21` (`company_id`),
  ADD KEY `waste_reports_index_22` (`report_date`),
  ADD KEY `waste_reports_index_23` (`status_id`),
  ADD KEY `waste_category_id` (`waste_category_id`);

--
-- Indexes for table `waste_tracking`
--
ALTER TABLE `waste_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `waste_tracking_index_78` (`company_id`),
  ADD KEY `waste_tracking_index_79` (`waste_category_id`),
  ADD KEY `waste_tracking_index_80` (`tracking_date`),
  ADD KEY `pickup_schedule_id` (`pickup_schedule_id`),
  ADD KEY `recycled_into_product_id` (`recycled_into_product_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bids`
--
ALTER TABLE `bids`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `blocked_industries`
--
ALTER TABLE `blocked_industries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `branches`
--
ALTER TABLE `branches`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=61;

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `ceo_messages`
--
ALTER TABLE `ceo_messages`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `companies`
--
ALTER TABLE `companies`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `company_users`
--
ALTER TABLE `company_users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `designations`
--
ALTER TABLE `designations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `drivers`
--
ALTER TABLE `drivers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `driver_tasks`
--
ALTER TABLE `driver_tasks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `email_messages`
--
ALTER TABLE `email_messages`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `garbage_report_donations`
--
ALTER TABLE `garbage_report_donations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `industry_priorities`
--
ALTER TABLE `industry_priorities`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `industry_ratings`
--
ALTER TABLE `industry_ratings`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `industry_rewards`
--
ALTER TABLE `industry_rewards`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `otps`
--
ALTER TABLE `otps`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `pickup_confirmations`
--
ALTER TABLE `pickup_confirmations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `pickup_schedules`
--
ALTER TABLE `pickup_schedules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=113;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `promotions`
--
ALTER TABLE `promotions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `public_garbage_reports`
--
ALTER TABLE `public_garbage_reports`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reward_tiers`
--
ALTER TABLE `reward_tiers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_history`
--
ALTER TABLE `service_history`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `three_bin_reports`
--
ALTER TABLE `three_bin_reports`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tutorial_slider`
--
ALTER TABLE `tutorial_slider`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `tutorial_topics`
--
ALTER TABLE `tutorial_topics`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `tutorial_videos`
--
ALTER TABLE `tutorial_videos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `types`
--
ALTER TABLE `types`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=204;

--
-- AUTO_INCREMENT for table `type_groups`
--
ALTER TABLE `type_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT for table `user_tutorial_progress`
--
ALTER TABLE `user_tutorial_progress`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `vehicle_locations`
--
ALTER TABLE `vehicle_locations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `waste_categories`
--
ALTER TABLE `waste_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `waste_reports`
--
ALTER TABLE `waste_reports`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `waste_tracking`
--
ALTER TABLE `waste_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bids`
--
ALTER TABLE `bids`
  ADD CONSTRAINT `bids_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `bids_ibfk_2` FOREIGN KEY (`waste_category_id`) REFERENCES `waste_categories` (`id`),
  ADD CONSTRAINT `bids_ibfk_3` FOREIGN KEY (`bid_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `bids_ibfk_4` FOREIGN KEY (`bid_status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `blocked_industries`
--
ALTER TABLE `blocked_industries`
  ADD CONSTRAINT `blocked_industries_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `blocked_industries_ibfk_2` FOREIGN KEY (`blocked_by_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `branches`
--
ALTER TABLE `branches`
  ADD CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`);

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `cart_items_ibfk_1` FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`),
  ADD CONSTRAINT `cart_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `ceo_messages`
--
ALTER TABLE `ceo_messages`
  ADD CONSTRAINT `ceo_messages_ibfk_1` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ceo_messages_ibfk_2` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ceo_messages_ibfk_3` FOREIGN KEY (`recipient_company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `ceo_messages_ibfk_4` FOREIGN KEY (`recipient_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `ceo_messages_ibfk_5` FOREIGN KEY (`message_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `ceo_messages_ibfk_6` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `companies`
--
ALTER TABLE `companies`
  ADD CONSTRAINT `companies_ibfk_1` FOREIGN KEY (`company_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `companies_ibfk_2` FOREIGN KEY (`business_type_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `company_users`
--
ALTER TABLE `company_users`
  ADD CONSTRAINT `company_users_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `company_users_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `company_users_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`);

--
-- Constraints for table `drivers`
--
ALTER TABLE `drivers`
  ADD CONSTRAINT `drivers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `driver_tasks`
--
ALTER TABLE `driver_tasks`
  ADD CONSTRAINT `driver_tasks_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `driver_tasks_ibfk_2` FOREIGN KEY (`pickup_schedule_id`) REFERENCES `pickup_schedules` (`id`),
  ADD CONSTRAINT `driver_tasks_ibfk_3` FOREIGN KEY (`task_status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `email_messages`
--
ALTER TABLE `email_messages`
  ADD CONSTRAINT `email_messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `email_messages_ibfk_2` FOREIGN KEY (`message_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `email_messages_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `garbage_report_donations`
--
ALTER TABLE `garbage_report_donations`
  ADD CONSTRAINT `garbage_report_donations_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `public_garbage_reports` (`id`),
  ADD CONSTRAINT `garbage_report_donations_ibfk_2` FOREIGN KEY (`donor_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `garbage_report_donations_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `industry_priorities`
--
ALTER TABLE `industry_priorities`
  ADD CONSTRAINT `industry_priorities_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `industry_priorities_ibfk_2` FOREIGN KEY (`last_updated_by_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `industry_ratings`
--
ALTER TABLE `industry_ratings`
  ADD CONSTRAINT `industry_ratings_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `industry_ratings_ibfk_2` FOREIGN KEY (`rated_by_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `industry_rewards`
--
ALTER TABLE `industry_rewards`
  ADD CONSTRAINT `industry_rewards_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `industry_rewards_ibfk_2` FOREIGN KEY (`current_tier_id`) REFERENCES `reward_tiers` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`sender_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`recipient_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `notifications_ibfk_3` FOREIGN KEY (`recipient_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `notifications_ibfk_4` FOREIGN KEY (`notification_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `notifications_ibfk_5` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `notifications_ibfk_6` FOREIGN KEY (`priority_level_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `orders_ibfk_3` FOREIGN KEY (`order_status_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `orders_ibfk_4` FOREIGN KEY (`payment_status_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `orders_ibfk_5` FOREIGN KEY (`payment_method_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `orders_ibfk_6` FOREIGN KEY (`promotion_id`) REFERENCES `promotions` (`id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  ADD CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `otps`
--
ALTER TABLE `otps`
  ADD CONSTRAINT `otps_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `otps_ibfk_2` FOREIGN KEY (`purpose_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `otps_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `pickup_confirmations`
--
ALTER TABLE `pickup_confirmations`
  ADD CONSTRAINT `pickup_confirmations_ibfk_1` FOREIGN KEY (`pickup_schedule_id`) REFERENCES `pickup_schedules` (`id`),
  ADD CONSTRAINT `pickup_confirmations_ibfk_2` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `pickup_confirmations_ibfk_3` FOREIGN KEY (`verification_status_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `pickup_confirmations_ibfk_4` FOREIGN KEY (`issue_reported_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `pickup_schedules`
--
ALTER TABLE `pickup_schedules`
  ADD CONSTRAINT `fk_pickup_schedules_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_1` FOREIGN KEY (`bid_id`) REFERENCES `bids` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_4` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_5` FOREIGN KEY (`pickup_status_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_6` FOREIGN KEY (`waste_type_id`) REFERENCES `waste_categories` (`id`),
  ADD CONSTRAINT `pickup_schedules_ibfk_7` FOREIGN KEY (`priority_level_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `product_categories` (`id`),
  ADD CONSTRAINT `products_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `promotions`
--
ALTER TABLE `promotions`
  ADD CONSTRAINT `promotions_ibfk_1` FOREIGN KEY (`discount_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `promotions_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `public_garbage_reports`
--
ALTER TABLE `public_garbage_reports`
  ADD CONSTRAINT `public_garbage_reports_ibfk_1` FOREIGN KEY (`reported_by_user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `public_garbage_reports_ibfk_2` FOREIGN KEY (`report_status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `regions`
--
ALTER TABLE `regions`
  ADD CONSTRAINT `regions_ibfk_1` FOREIGN KEY (`parent_region_id`) REFERENCES `regions` (`id`);

--
-- Constraints for table `service_history`
--
ALTER TABLE `service_history`
  ADD CONSTRAINT `fk_service_collected_by` FOREIGN KEY (`collected_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `service_history_ibfk_1` FOREIGN KEY (`pickup_confirmation_id`) REFERENCES `pickup_confirmations` (`id`),
  ADD CONSTRAINT `service_history_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `service_history_ibfk_3` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  ADD CONSTRAINT `service_history_ibfk_4` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `service_history_ibfk_5` FOREIGN KEY (`waste_category_id`) REFERENCES `waste_categories` (`id`);

--
-- Constraints for table `three_bin_reports`
--
ALTER TABLE `three_bin_reports`
  ADD CONSTRAINT `fk_three_bin_report_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `three_bin_reports_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `three_bin_reports_ibfk_2` FOREIGN KEY (`pickup_schedule_id`) REFERENCES `pickup_schedules` (`id`);

--
-- Constraints for table `tutorial_slider`
--
ALTER TABLE `tutorial_slider`
  ADD CONSTRAINT `tutorial_slider_ibfk_1` FOREIGN KEY (`video_id`) REFERENCES `tutorial_videos` (`id`);

--
-- Constraints for table `tutorial_videos`
--
ALTER TABLE `tutorial_videos`
  ADD CONSTRAINT `tutorial_videos_ibfk_1` FOREIGN KEY (`topic_id`) REFERENCES `tutorial_topics` (`id`);

--
-- Constraints for table `types`
--
ALTER TABLE `types`
  ADD CONSTRAINT `types_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `type_groups` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`user_type_id`) REFERENCES `types` (`id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`designation_id`) REFERENCES `designations` (`id`);

--
-- Constraints for table `user_tutorial_progress`
--
ALTER TABLE `user_tutorial_progress`
  ADD CONSTRAINT `user_tutorial_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `user_tutorial_progress_ibfk_2` FOREIGN KEY (`tutorial_video_id`) REFERENCES `tutorial_videos` (`id`);

--
-- Constraints for table `vehicle_locations`
--
ALTER TABLE `vehicle_locations`
  ADD CONSTRAINT `vehicle_locations_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `vehicle_locations_ibfk_2` FOREIGN KEY (`vehicle_id`) REFERENCES `drivers` (`id`),
  ADD CONSTRAINT `vehicle_locations_ibfk_3` FOREIGN KEY (`pickup_schedule_id`) REFERENCES `pickup_schedules` (`id`),
  ADD CONSTRAINT `vehicle_locations_ibfk_4` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`);

--
-- Constraints for table `waste_reports`
--
ALTER TABLE `waste_reports`
  ADD CONSTRAINT `waste_reports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `waste_reports_ibfk_2` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `waste_reports_ibfk_3` FOREIGN KEY (`waste_category_id`) REFERENCES `waste_categories` (`id`),
  ADD CONSTRAINT `waste_reports_ibfk_4` FOREIGN KEY (`status_id`) REFERENCES `types` (`id`);

--
-- Constraints for table `waste_tracking`
--
ALTER TABLE `waste_tracking`
  ADD CONSTRAINT `waste_tracking_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  ADD CONSTRAINT `waste_tracking_ibfk_2` FOREIGN KEY (`pickup_schedule_id`) REFERENCES `pickup_schedules` (`id`),
  ADD CONSTRAINT `waste_tracking_ibfk_3` FOREIGN KEY (`waste_category_id`) REFERENCES `waste_categories` (`id`),
  ADD CONSTRAINT `waste_tracking_ibfk_4` FOREIGN KEY (`recycled_into_product_id`) REFERENCES `products` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
