"use client";
import Link from "next/link";
import { useEffect, useState } from "react";
import BrandLogo from "~/components/Ui/Logo/BrandLogo";
import {
  Home,
  Zap,
  HelpCircle,
  FileText,
  X,
  Download,
  ArrowRight,
} from "lucide-react";

const HomeHeaderTwo = ({ logoSrc }) => {
  const [isActive, setIsActive] = useState(false);
  const [scrollClassName, setScrollClassName] = useState("");

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 100) {
        setScrollClassName("sticky-menu");
      } else {
        setScrollClassName("");
      }
    };

    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  }, []);

  const toggleMenu = () => {
    setIsActive(!isActive);
    document.body.style.overflow = isActive ? "auto" : "hidden";
  };

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 991 && isActive) {
        toggleMenu();
      }
    };

    window.addEventListener("resize", handleResize);
    return () => {
      window.removeEventListener("resize", handleResize);
    };
  }, [isActive]);

  const scrollToSection = (id) => {
    const section = document.getElementById(id);
    if (section) {
      window.scrollTo({
        top: section.offsetTop - 80, // Adjust for header height
        behavior: "smooth",
      });
    }
    setIsActive(false);
    document.body.style.overflow = "auto";
  };

  const menuItems = [
    { icon: <Home size={20} />, label: "Home", id: "home" },
    { icon: <Zap size={20} />, label: "Features", id: "features" },
    { icon: <HelpCircle size={20} />, label: "Why Us?", id: "why-us" },
    { icon: <FileText size={20} />, label: "News", id: "news" },
  ];

  return (
    <header
      className={`site-header zubuz-header-section bg-white ${scrollClassName}`}
      id="sticky-menu"
    >
      <div className="container">
        <nav className="navbar site-navbar">
          <BrandLogo imageSrc={logoSrc} />
          <div className="menu-block-wrapper d-none d-lg-block">
            <nav className="menu-block">
              <ul className="site-menu-main">
                {menuItems.map((item, index) => (
                  <li key={index} className="nav-item">
                    <button
                      className="nav-link-item"
                      onClick={() => scrollToSection(item.id)}
                      style={{
                        background: "none",
                        border: "none",
                        cursor: "pointer",
                      }}
                    >
                      {item.label}
                    </button>
                  </li>
                ))}
              </ul>
            </nav>
          </div>

          <div className="header-btn header-btn-l1 ms-auto d-none d-xs-inline-flex">
            <Link
              className="zubuz-default-btn zubuz-header-btn pill"
              href="https://docs.google.com/forms/d/e/1FAIpQLSfzlQ-MxRn3xyZ4yj3fxFtkgwz6r_ZwzUdA5Ocp72-5Bkr-dA/viewform"
            >
              <span>Download</span>
            </Link>
          </div>
          <div
            className="mobile-menu-trigger light d-lg-none"
            onClick={toggleMenu}
          >
            <span></span>
          </div>
        </nav>
      </div>

      {/* Right Side Drawer Menu */}
      <div
        className={`drawer-menu-overlay ${isActive ? "active" : ""}`}
        onClick={toggleMenu}
      ></div>
      <div className={`drawer-menu ${isActive ? "active" : ""}`}>
        <div className="drawer-menu-inner">
          <div className="drawer-header">
            <div className="drawer-brand">
              <BrandLogo imageSrc={logoSrc} />
            </div>
            <button className="drawer-close" onClick={toggleMenu}>
              <X size={20} />
            </button>
          </div>

          <div className="drawer-body">
            <nav className="drawer-nav">
              {menuItems.map((item, index) => (
                <button
                  key={index}
                  className="drawer-nav-item"
                  onClick={() => scrollToSection(item.id)}
                  style={{
                    background: "none",
                    border: "none",
                    cursor: "pointer",
                    width: "100%",
                  }}
                >
                  <div className="drawer-nav-icon">{item.icon}</div>
                  <div className="drawer-nav-content">
                    <span className="drawer-nav-label">{item.label}</span>
                    <ArrowRight size={14} className="drawer-nav-arrow" />
                  </div>
                </button>
              ))}
            </nav>
          </div>

          <div className="drawer-footer">
            <div className="drawer-download">
              <h4 className="drawer-title">Get our mobile app</h4>
            </div>

            <div className="drawer-stores">
              <a href="https://docs.google.com/forms/d/e/1FAIpQLSfzlQ-MxRn3xyZ4yj3fxFtkgwz6r_ZwzUdA5Ocp72-5Bkr-dA/viewform" className="drawer-store-btn">
                <img src="/images/v1/app-store.png" alt="App Store" />
              </a>
              <a href="https://docs.google.com/forms/d/e/1FAIpQLSfzlQ-MxRn3xyZ4yj3fxFtkgwz6r_ZwzUdA5Ocp72-5Bkr-dA/viewform" className="drawer-store-btn">
                <img src="/images/v1/play-store.png" alt="Play Store" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default HomeHeaderTwo;
