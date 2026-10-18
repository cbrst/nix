import { Inter } from 'next/font/google';
import type { Metadata } from 'next';
import { Provider } from '@/components/provider';
import { appName, basePath } from '@/lib/shared';
import './global.css';

const inter = Inter({
  subsets: ['latin'],
});

export const metadata: Metadata = {
  metadataBase: new URL('https://cbrst.github.io'),
  title: {
    template: `%s | ${appName}`,
    default: appName,
  },
  description: 'A NixOS and Home Manager flake for Linux workstations and macOS.',
  // Metadata URLs are not prefixed with basePath, so add it explicitly.
  icons: {
    icon: [
      {
        url: `${basePath}/nix-snowflake-colours.svg`,
        type: 'image/svg+xml',
        media: '(prefers-color-scheme: light)',
      },
      {
        url: `${basePath}/nix-snowflake-white.svg`,
        type: 'image/svg+xml',
        media: '(prefers-color-scheme: dark)',
      },
      {
        url: `${basePath}/favicon-32.png`,
        sizes: '32x32',
        type: 'image/png',
        media: '(prefers-color-scheme: light)',
      },
      {
        url: `${basePath}/favicon-32-white.png`,
        sizes: '32x32',
        type: 'image/png',
        media: '(prefers-color-scheme: dark)',
      },
    ],
    apple: `${basePath}/apple-touch-icon.png`,
  },
};

export default function Layout({ children }: LayoutProps<'/'>) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <body className="flex flex-col min-h-screen">
        <Provider>{children}</Provider>
      </body>
    </html>
  );
}
