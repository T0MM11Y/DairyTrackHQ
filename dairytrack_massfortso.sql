-- phpMyAdmin SQL Dump
-- version 5.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 26, 2025 at 03:28 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dairytrack_massfortso`
--

-- --------------------------------------------------------

--
-- Table structure for table `blogs`
--

CREATE TABLE `blogs` (
  `id` int(11) NOT NULL,
  `title` varchar(150) NOT NULL,
  `photo_url` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `blogs`
--

INSERT INTO `blogs` (`id`, `title`, `photo_url`, `content`, `created_at`, `updated_at`) VALUES
(2, 'Optimizing Cattle Feed to Maximize Milk Production: A Complete Guide', 'istockph_0c1c0db.jpg', '<p>Understanding the direct relationship between cattle nutrition and milk yield is crucial for dairy farmers seeking to optimize their operations. High-quality feed directly impacts both the quantity and quality of milk produced by dairy cows.</p><p><br></p><p>Feed Composition for Maximum Milk Production: The foundation of excellent milk production lies in providing cattle with a balanced diet rich in proteins, carbohydrates, fats, vitamins, and minerals. A typical high-producing dairy cow requires 3-4% of her body weight in dry matter daily. The ideal feed should contain 16-18% crude protein and adequate energy levels measured in Total Digestible Nutrients (TDN).</p><p><br></p><p>Key Feed Components:</p><p><br></p><ol><li>Forages (hay, silage, pasture): 50-60% of total diet</li><li>Concentrates (grains, protein meals): 40-50% of total diet</li><li>Vitamin and mineral supplements: 2-5% of total diet</li></ol><p>Impact on Milk Quality: Proper nutrition not only increases milk volume but also improves milk composition, including fat content, protein levels, and overall nutritional value. Cows fed premium feed can produce 20-30% more milk compared to those on basic diets.</p><p><br></p><p>Regular monitoring of feed quality and adjusting rations based on milk production data ensures optimal results and maximizes farm profitability.</p>', '2025-05-24 17:14:04', '2025-05-24 17:19:15'),
(3, 'Healthy Cattle, Higher Profits: How Animal Wellness Drives Market Success', 'animals-_8f1bab9.png', '<p>The connection between cattle health and market profitability is undeniable. Healthy cattle not only produce better quality products but also command premium prices in the marketplace.</p><p><br></p><p>Health Management for Market Success: Implementing comprehensive health protocols is essential for maintaining cattle that meet market standards. Regular veterinary check-ups, vaccination schedules, and preventive care programs form the backbone of successful cattle operations.</p><p><br></p><p>Key Health Indicators:</p><p><br></p><ol><li>Body condition scoring</li><li>Milk quality tests (somatic cell count, bacterial count)</li><li>Reproductive health metrics</li><li>Feed conversion efficiency</li></ol><p><br></p><p>Marketing Healthy Cattle Products: Consumers increasingly demand products from healthy, well-cared-for animals. This presents opportunities for premium pricing and brand differentiation. Health certifications and transparency in animal care practices can be powerful marketing tools.</p><p><br></p><p>Building Consumer Trust: Documenting health practices through digital records and sharing this information with consumers builds trust and justifies premium pricing. Social media platforms and farm visits can showcase healthy cattle management practices.</p><p><br></p><p>Return on Investment: While health programs require initial investment, the long-term benefits include reduced veterinary costs, improved productivity, and access to premium markets that can increase profits by 15-25%.</p><p><br></p>', '2025-05-24 17:46:10', '2025-05-24 17:46:10'),
(4, 'From Farm to Market: Strategies for Maximizing Milk Production Revenue', 'GettyIma_59a04b3.jpg', '<p>Converting high milk production into profitable sales requires strategic planning and market understanding. Success depends on both optimizing production efficiency and implementing effective marketing strategies.</p><p><br></p><p>Production Optimization: Maximizing milk production starts with proper herd management, including selective breeding programs, optimal milking schedules, and maintaining ideal environmental conditions. Modern dairy operations can achieve 25-30 liters per cow per day with proper management.</p><p><br></p><p>Quality Standards for Premium Markets: Meeting strict quality standards opens doors to premium markets. This includes maintaining low somatic cell counts (under 200,000), ensuring proper storage temperatures, and implementing HACCP protocols.</p><p><br></p><p>Market Segmentation Strategies: Different market segments offer varying profit margins:</p><p><br></p><ol><li>Organic milk: 30-40% premium over conventional</li><li>Local/artisanal markets: 20-25% premium</li><li>Direct-to-consumer sales: 40-50% higher margins</li><li>Wholesale markets: Volume-based pricing</li></ol><p><br></p><p>Value-Added Products: Processing milk into cheese, yogurt, or specialty products can increase profit margins by 100-200%. Consider partnerships with local processors or invest in on-farm processing facilities.</p><p><br></p><p>Digital Marketing for Dairy: Utilizing social media, farm websites, and e-commerce platforms helps reach new customers and build brand loyalty. Sharing the farm story and production practices resonates with modern consumers.</p>', '2025-05-24 17:49:53', '2025-05-24 17:49:53'),
(5, 'Nutritional Immunology: How Proper Feed Boosts Cattle Health and Disease Resistance', 'How_to_I_dc513ff.png', '<p>The immune system of cattle is heavily influenced by nutrition. Strategic feeding programs can significantly enhance natural disease resistance and reduce veterinary costs.</p><p><br></p><p>Feed-Based Immunity Enhancement: Certain feed components act as immune boosters. Vitamin E, selenium, zinc, and specific probiotics strengthen the immune system and help cattle resist common diseases like mastitis, respiratory infections, and digestive disorders.</p><p><br></p><p>Critical Nutrients for Health:</p><p><br></p><ol><li>Vitamin A: Essential for epithelial tissue health and resistance to respiratory diseases</li><li>Vitamin E and Selenium: Powerful antioxidants that support immune function</li><li>Zinc: Crucial for wound healing and immune response</li><li>Probiotics: Maintain healthy gut microbiome and improve nutrient absorption</li></ol><p><br></p><p>Stress Reduction Through Nutrition: Proper nutrition helps cattle cope with environmental stressors that can compromise immune function. Consistent feed quality and availability reduce stress-related health issues.</p><p><br></p><p>Economic Benefits: Investing in immune-supporting nutrition can reduce veterinary costs by 30-40% while improving overall herd productivity. The cost-benefit ratio typically favors nutritional prevention over treatment.</p><p><br></p><p>Monitoring and Adjustment: Regular health assessments should guide feed adjustments. Blood tests can reveal nutritional deficiencies that may compromise immune function, allowing for targeted supplementation.</p>', '2025-05-24 17:52:57', '2025-05-24 17:52:57'),
(6, 'The Integrated Approach: Connecting Feed, Health, Production, and Profitability in Modern Cattle Operations', 'sensors-_fad8b64.jpg', '<p>Successful cattle operations require integration across all aspects of management. Feed quality affects health, health impacts production, and production efficiency determines market profitability.</p><p><br></p><p>The Feed-Health-Production Cycle: Quality feed promotes optimal health, which enables maximum production capacity. This creates a positive cycle where each element reinforces the others. Breaking this cycle at any point can have cascading negative effects.</p><p><br></p><p>Holistic Management Strategies: Modern cattle operations must consider all factors simultaneously:</p><p><br></p><p>Feed Management:</p><ol><li>Seasonal feed planning and storage</li><li>Regular feed testing and adjustment</li><li>Cost-effective sourcing strategies</li></ol><p><br></p><p>Health Protocols:</p><ol><li>Preventive medicine programs</li><li>Early disease detection systems</li><li>Biosecurity measures</li></ol><p><br></p><p>Production Optimization:</p><ol><li>Genetic selection for productivity traits</li><li>Environmental management for comfort</li><li>Technology integration for monitoring</li></ol><p><br></p><p>Market Positioning:</p><ol><li>Brand development based on quality practices</li><li>Diversified revenue streams</li><li>Customer relationship management</li></ol><p><br></p><p>Technology Integration: Modern farms use sensors, data analytics, and automated systems to monitor all aspects simultaneously. This allows for real-time adjustments and optimization across all categories.</p><p><br></p><p>Financial Planning: Successful integration requires careful financial planning to balance investments across feed, health, production infrastructure, and marketing initiatives for maximum return on investment.</p>', '2025-05-24 18:17:16', '2025-05-24 18:17:16');

-- --------------------------------------------------------

--
-- Table structure for table `blog_categories`
--

CREATE TABLE `blog_categories` (
  `blog_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `blog_categories`
--

INSERT INTO `blog_categories` (`blog_id`, `category_id`) VALUES
(2, 1),
(2, 2),
(3, 3),
(3, 4),
(4, 2),
(4, 4),
(5, 1),
(5, 3),
(6, 1),
(6, 2),
(6, 3),
(6, 4);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Cattle Feed', 'Insights, tips, and innovations related to feeding dairy cows — from nutritional requirements to types of forage and supplements.', '2025-05-24 17:04:38', '2025-05-24 17:04:38'),
(2, 'Milk Production', 'Everything about milk yield, milking techniques, equipment, and best practices to improve dairy productivity.', '2025-05-24 17:05:01', '2025-05-24 17:05:01'),
(3, 'Cattle Health', 'Articles focused on maintaining and improving the health of dairy cows, including disease prevention, treatment, and veterinary care.', '2025-05-24 17:05:18', '2025-05-24 17:05:18'),
(4, 'Marketing', 'Guidance on selling dairy products, market trends, pricing strategies, and distribution tips for maximizing profit.', '2025-05-24 17:05:40', '2025-05-24 17:05:40');

-- --------------------------------------------------------

--
-- Table structure for table `cows`
--

CREATE TABLE `cows` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `birth` date NOT NULL,
  `breed` varchar(50) NOT NULL,
  `lactation_phase` varchar(50) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `gender` varchar(10) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cows`
--

INSERT INTO `cows` (`id`, `name`, `birth`, `breed`, `lactation_phase`, `weight`, `gender`, `created_at`, `updated_at`) VALUES
(1, 'Daisy', '2022-04-14', 'Girolando', 'Mid', 500, 'Female', '2025-05-24 13:54:10', '2025-05-24 14:54:33'),
(2, 'Max', '2020-03-14', 'Girolando', '-', 950, 'Male', '2025-05-24 15:07:53', '2025-05-24 15:07:53'),
(3, 'Rosie', '2022-03-11', 'Girolando', 'Mid', 450, 'Female', '2025-05-24 15:17:09', '2025-05-24 15:17:09'),
(4, 'Jenny', '2023-02-14', 'Girolando', 'Early', 450, 'Female', '2025-05-25 02:08:24', '2025-05-25 02:08:24');

-- --------------------------------------------------------

--
-- Table structure for table `daily_milk_summary`
--

CREATE TABLE `daily_milk_summary` (
  `id` int(11) NOT NULL,
  `cow_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `morning_volume` float NOT NULL,
  `afternoon_volume` float NOT NULL,
  `evening_volume` float NOT NULL,
  `total_volume` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `daily_milk_summary`
--

INSERT INTO `daily_milk_summary` (`id`, `cow_id`, `date`, `morning_volume`, `afternoon_volume`, `evening_volume`, `total_volume`) VALUES
(1, 1, '2025-05-25', 6, 0, 20, 26),
(3, 3, '2025-05-24', 5, 0, 0, 5),
(4, 4, '2025-05-25', 7, 0, 38, 45),
(5, 3, '2025-05-25', 21, 0, 12, 33),
(6, 3, '2025-05-26', 12, 12, 0, 24),
(7, 1, '2025-05-26', 5, 0, 0, 5);

-- --------------------------------------------------------

--
-- Table structure for table `galleries`
--

CREATE TABLE `galleries` (
  `id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `image_url` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `galleries`
--

INSERT INTO `galleries` (`id`, `title`, `image_url`, `created_at`, `updated_at`) VALUES
(2, 'A Day in the Life of a Dairy Farm', 'premium__c51f1c4.jpg', '2025-05-24 16:13:37', '2025-05-24 16:13:37'),
(3, 'Calves: The Future of the Dairy Herd', 'photo-15_8b7aaec.jpg', '2025-05-24 16:21:14', '2025-05-24 16:21:14'),
(4, 'Daily Rhythms in a Modern Dairy Barn', 'premium__b9cc65e.jpg', '2025-05-24 16:26:37', '2025-05-24 16:26:37'),
(5, 'Healthy Cows, Quality Milk', 'premium__2b09d11.jpg', '2025-05-24 16:27:58', '2025-05-24 16:27:58'),
(6, 'The Life of Dairy Cattle: Nutrition and Care', 'photo-16_d23b57e.jpg', '2025-05-24 16:28:47', '2025-05-24 16:28:47'),
(7, 'The Gentle Eyes of Dairy Cows', 'photo-17_0093d52.jpg', '2025-05-24 16:29:17', '2025-05-24 16:36:46'),
(8, 'Harmony in the Herd', 'photo-17_b32559e.jpg', '2025-05-24 16:37:33', '2025-05-24 16:37:33'),
(9, 'Summer Grazing Scenes', 'photo-17_13a7caf.jpg', '2025-05-24 16:38:13', '2025-05-24 16:38:13'),
(10, 'Behind the Barn Doors', 'photo-17_3cd80d9.jpg', '2025-05-24 16:39:29', '2025-05-24 16:39:29'),
(11, 'Dairy Cows in Motion: Grazing and Wandering', 'photo-17_4adffd0.jpg', '2025-05-24 16:39:57', '2025-05-24 16:39:57'),
(12, 'Grass-Fed and Graceful', 'photo-17_859a9bc.jpg', '2025-05-24 16:41:51', '2025-05-24 16:41:51'),
(13, 'The Quiet Strength of Dairy Herds', 'photo-15_3533068.jpg', '2025-05-24 16:45:43', '2025-05-24 16:45:43'),
(14, 'Morning Milking Rituals', 'photo-16_c3956cb.jpg', '2025-05-24 16:46:30', '2025-05-24 16:46:30');

-- --------------------------------------------------------

--
-- Table structure for table `milking_sessions`
--

CREATE TABLE `milking_sessions` (
  `id` int(11) NOT NULL,
  `cow_id` int(11) NOT NULL,
  `milker_id` int(11) NOT NULL,
  `milk_batch_id` int(11) DEFAULT NULL,
  `volume` float NOT NULL,
  `milking_time` datetime NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `milking_sessions`
--

INSERT INTO `milking_sessions` (`id`, `cow_id`, `milker_id`, `milk_batch_id`, `volume`, `milking_time`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 1, 6, '2025-05-25 07:21:00', 'Daisy cooperative, normal milk quality, no issues\n\nCreated by: Novita Dewi (Role: Admin)', '2025-05-24 19:23:18', '2025-05-24 19:23:18'),
(6, 3, 4, 6, 5, '2025-05-24 07:42:00', 'Cow slightly restless, volume down a bit, monitor tomorrow\n\nCreated by: Novita Dewi (Role: Admin)', '2025-05-24 19:43:47', '2025-05-24 19:43:47'),
(10, 1, 3, 10, 7, '2025-05-25 19:08:00', 'Created by: Sukamto (Role: Farmer)', '2025-05-24 20:15:19', '2025-05-24 20:15:19'),
(15, 4, 3, 15, 7, '2025-05-25 09:09:00', 'Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:11:25', '2025-05-25 02:11:25'),
(20, 4, 3, 20, 6, '2025-05-25 18:25:00', 'Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:25:46', '2025-05-25 02:25:46'),
(21, 4, 3, 21, 19, '2025-05-25 21:26:00', 'Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:27:01', '2025-05-25 02:27:22'),
(22, 1, 3, 22, 13, '2025-05-25 21:29:00', 'Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:30:13', '2025-05-25 02:30:13'),
(23, 3, 4, 23, 21, '2025-05-25 09:48:00', 'Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:48:27', '2025-05-25 02:48:27'),
(24, 3, 4, 24, 12, '2025-05-25 21:50:00', 'Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:50:20', '2025-05-25 02:50:20'),
(25, 4, 3, 25, 13, '2025-05-25 22:41:00', 'Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 03:41:54', '2025-05-25 03:41:54'),
(26, 3, 4, 26, 12, '2025-05-26 17:49:00', 'Created by: Siti Wati (Role: Farmer, ID: 4)', '2025-05-25 04:49:56', '2025-05-25 04:49:56'),
(27, 3, 4, 27, 12, '2025-05-26 08:19:00', 'Sapi diperah dengan mudah\n\nCreated by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-26 01:19:38', '2025-05-26 01:19:38'),
(28, 1, 3, 28, 5, '2025-05-26 08:21:00', 'sapi diperah dengan mudah\n\nCreated by: Sukamto (Role: Farmer, ID: 3)', '2025-05-26 01:21:40', '2025-05-26 01:21:40');

-- --------------------------------------------------------

--
-- Table structure for table `milk_batches`
--

CREATE TABLE `milk_batches` (
  `id` int(11) NOT NULL,
  `batch_number` varchar(50) NOT NULL,
  `total_volume` float NOT NULL,
  `status` enum('FRESH','EXPIRED','USED') NOT NULL,
  `production_date` datetime NOT NULL,
  `expiry_date` datetime DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `milk_batches`
--

INSERT INTO `milk_batches` (`id`, `batch_number`, `total_volume`, `status`, `production_date`, `expiry_date`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'BATCH-20250524192318', 6, 'FRESH', '2025-05-25 07:21:00', '2025-05-25 15:21:00', 'Auto-generated batch from milking session. Daisy cooperative, normal milk quality, no issues\n\nCreated by: Novita Dewi (Role: Admin)', '2025-05-24 19:23:18', '2025-05-24 19:23:18'),
(6, 'BATCH-20250524194347', 5, 'EXPIRED', '2025-05-24 07:42:00', '2025-05-24 15:42:00', 'Auto-generated batch from milking session. Cow slightly restless, volume down a bit, monitor tomorrow\n\nCreated by: Novita Dewi (Role: Admin)', '2025-05-24 19:43:47', '2025-05-24 19:48:52'),
(10, 'BATCH-20250524201519', 7, 'FRESH', '2025-05-25 19:08:00', '2025-05-26 03:08:00', 'Auto-generated batch from milking session. Created by: Sukamto (Role: Farmer)', '2025-05-24 20:15:19', '2025-05-24 20:15:19'),
(15, 'BATCH-20250525021125', 7, 'FRESH', '2025-05-25 09:09:00', '2025-05-25 17:09:00', 'Auto-generated batch from milking session. Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:11:25', '2025-05-25 02:11:25'),
(20, 'BATCH-20250525022546', 6, 'FRESH', '2025-05-25 18:25:00', '2025-05-26 02:25:00', 'Auto-generated batch from milking session. Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:25:46', '2025-05-25 02:25:46'),
(21, 'BATCH-20250525022701', 19, 'FRESH', '2025-05-25 21:26:00', '2025-05-26 05:26:00', 'Auto-generated batch from milking session. Created by: Sukamto (Role: Farmer, ID: 3)', '2025-05-25 02:27:01', '2025-05-25 02:27:22'),
(22, 'BATCH-20250525023013', 13, 'FRESH', '2025-05-25 21:29:00', '2025-05-26 05:29:00', 'Auto-generated batch from milking session. Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:30:13', '2025-05-25 02:30:13'),
(23, 'BATCH-20250525024827', 21, 'FRESH', '2025-05-25 09:48:00', '2025-05-25 17:48:00', 'Auto-generated batch from milking session. Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:48:27', '2025-05-25 02:48:27'),
(24, 'BATCH-20250525025020', 12, 'FRESH', '2025-05-25 21:50:00', '2025-05-26 05:50:00', 'Auto-generated batch from milking session. Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 02:50:20', '2025-05-25 02:50:20'),
(25, 'BATCH-20250525034154', 13, 'FRESH', '2025-05-25 22:41:00', '2025-05-26 06:41:00', 'Auto-generated batch from milking session. Created by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-25 03:41:54', '2025-05-25 03:41:54'),
(26, 'BATCH-20250525044956', 12, 'FRESH', '2025-05-26 17:49:00', '2025-05-27 01:49:00', 'Auto-generated batch from milking session. Created by: Siti Wati (Role: Farmer, ID: 4)', '2025-05-25 04:49:56', '2025-05-25 04:49:56'),
(27, 'BATCH-20250526011938', 12, 'FRESH', '2025-05-26 08:19:00', '2025-05-26 16:19:00', 'Auto-generated batch from milking session. Sapi diperah dengan mudah\n\nCreated by: Novita Dewi (Role: Admin, ID: 2)', '2025-05-26 01:19:38', '2025-05-26 01:19:38'),
(28, 'BATCH-20250526012140', 5, 'FRESH', '2025-05-26 08:21:00', '2025-05-26 16:21:00', 'Auto-generated batch from milking session. sapi diperah dengan mudah\n\nCreated by: Sukamto (Role: Farmer, ID: 3)', '2025-05-26 01:21:40', '2025-05-26 01:21:40');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `cow_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `type` varchar(20) NOT NULL,
  `is_read` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `created_at_wib` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `cow_id`, `message`, `type`, `is_read`, `created_at`, `created_at_wib`) VALUES
(2, 4, 3, 'Batch BATCH-20250524194347 with 5.0 liters from cow Rosie has expired at 15:42:00 on 24/05/2025.', 'milk_expiry', 1, '2025-05-25 02:48:52', '2025-05-25 02:48:52'),
(3, 3, 1, 'Produksi susu rendah! Sapi #1 (Daisy) hanya memproduksi 13.0 liter hari ini (di bawah standar 15L)', 'low_production', 0, '2025-05-25 03:15:19', '2025-05-25 03:15:19'),
(4, 4, 3, 'PERINGATAN: Batch BATCH-20250524194852 dengan 7.0 liter dari sapi Rosie akan kadaluarsa dalam 1.5 jam pada 03:48:00 on 25/05/2025. Segera gunakan atau olah!', 'milk_warning', 1, '2025-05-25 09:17:01', '2025-05-25 09:17:01'),
(5, 3, 4, 'Produksi susu rendah! Sapi #4 (Jenny) hanya memproduksi 13.0 liter hari ini (di bawah standar 15L)', 'low_production', 0, '2025-05-25 09:25:46', '2025-05-25 09:25:46'),
(6, 3, 4, 'Produksi susu tinggi! Sapi #4 (Jenny) memproduksi 45.0 liter hari ini (di atas standar 25L)', 'high_production', 0, '2025-05-25 04:49:56', '2025-05-25 09:27:22'),
(7, 3, 1, 'Produksi susu tinggi! Sapi #1 (Daisy) memproduksi 26.0 liter hari ini (di atas standar 25L)', 'high_production', 0, '2025-05-25 04:49:56', '2025-05-25 09:30:13'),
(9, 4, 3, 'Produksi susu tinggi! Sapi #3 (Rosie) memproduksi 33.0 liter hari ini (di atas standar 25L)', 'high_production', 0, '2025-05-25 04:49:56', '2025-05-25 10:41:54');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`) VALUES
(1, 'Admin', 'Full access to view, add, edit, and delete all data'),
(2, 'Supervisor', 'Read-only access. Cannot add, edit or delete data'),
(3, 'Farmer', 'Can manage data related to assigned cows only');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `contact` varchar(15) DEFAULT NULL,
  `religion` varchar(50) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `token` varchar(255) DEFAULT NULL,
  `token_created_at` datetime DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `birth` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password`, `contact`, `religion`, `role_id`, `token`, `token_created_at`, `name`, `birth`) VALUES
(1, 'supervisor_andre', 'andre.wijaya@example.com', 'pbkdf2:sha256:260000$oI74eY66xGnHzb7E$5dfe4479bc7b95847aab25ad74a95732d713e71be8f64739d3224f2f6fe35891', '082112345678', 'Kristen', 2, NULL, NULL, 'Andre Wijaya', '1985-09-14'),
(2, 'admin_novita', 'novita.dewi@example.com', 'pbkdf2:sha256:260000$HCNmQ3Y0sXkO8ZQM$65a3110a7b8fd21def4ec9bac9a4cb57c3b68661362ac982ab92bc247dff92d2', '085212344567', 'Catholicism', 1, NULL, NULL, 'Novita Dewi', '1991-09-18'),
(3, 'farmer_sukamto', 'sukamto.farmer@example.com', 'pbkdf2:sha256:260000$KRLGVWEc28Ql5kXa$ea1000cb4e90268f73ac1289bab2f6bd27d805780ccc07dfc65ce68d17e9bfb1', '081345678900', 'Catholicism', 3, '2e93a1af-e86a-4eb4-b2eb-b3de197e6750', '2025-05-26 01:21:10', 'Sukamto', '1996-05-23'),
(4, 'farmer_wati', 'siti.wati@example.com', 'pbkdf2:sha256:260000$P2ozzoZqV7yg8fRH$21a2d72b50e84b92edad72409af904d5145800ecf1b12a137eb5375c3b936800', '082234567899', 'Hinduism', 3, NULL, NULL, 'Siti Wati', '1999-05-10');

-- --------------------------------------------------------

--
-- Table structure for table `user_cow_association`
--

CREATE TABLE `user_cow_association` (
  `user_id` int(11) NOT NULL,
  `cow_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user_cow_association`
--

INSERT INTO `user_cow_association` (`user_id`, `cow_id`) VALUES
(3, 1),
(3, 2),
(3, 4),
(4, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `blogs`
--
ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD PRIMARY KEY (`blog_id`,`category_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `cows`
--
ALTER TABLE `cows`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `daily_milk_summary`
--
ALTER TABLE `daily_milk_summary`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cow_id` (`cow_id`);

--
-- Indexes for table `galleries`
--
ALTER TABLE `galleries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `milking_sessions`
--
ALTER TABLE `milking_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cow_id` (`cow_id`),
  ADD KEY `milk_batch_id` (`milk_batch_id`),
  ADD KEY `milker_id` (`milker_id`);

--
-- Indexes for table `milk_batches`
--
ALTER TABLE `milk_batches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `batch_number` (`batch_number`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cow_id` (`cow_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `role_id` (`role_id`);

--
-- Indexes for table `user_cow_association`
--
ALTER TABLE `user_cow_association`
  ADD PRIMARY KEY (`user_id`,`cow_id`),
  ADD KEY `cow_id` (`cow_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blogs`
--
ALTER TABLE `blogs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `cows`
--
ALTER TABLE `cows`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `daily_milk_summary`
--
ALTER TABLE `daily_milk_summary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `galleries`
--
ALTER TABLE `galleries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `milking_sessions`
--
ALTER TABLE `milking_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `milk_batches`
--
ALTER TABLE `milk_batches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD CONSTRAINT `blog_categories_ibfk_1` FOREIGN KEY (`blog_id`) REFERENCES `blogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `blog_categories_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `daily_milk_summary`
--
ALTER TABLE `daily_milk_summary`
  ADD CONSTRAINT `daily_milk_summary_ibfk_1` FOREIGN KEY (`cow_id`) REFERENCES `cows` (`id`);

--
-- Constraints for table `milking_sessions`
--
ALTER TABLE `milking_sessions`
  ADD CONSTRAINT `milking_sessions_ibfk_1` FOREIGN KEY (`cow_id`) REFERENCES `cows` (`id`),
  ADD CONSTRAINT `milking_sessions_ibfk_2` FOREIGN KEY (`milk_batch_id`) REFERENCES `milk_batches` (`id`),
  ADD CONSTRAINT `milking_sessions_ibfk_3` FOREIGN KEY (`milker_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`cow_id`) REFERENCES `cows` (`id`),
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);

--
-- Constraints for table `user_cow_association`
--
ALTER TABLE `user_cow_association`
  ADD CONSTRAINT `user_cow_association_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_cow_association_ibfk_2` FOREIGN KEY (`cow_id`) REFERENCES `cows` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
