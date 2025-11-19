import prisma from '../config/database';

interface Campaign {
  id: string;
  name: string;
  description?: string;
  type: string;
  status: string;
  targetCount: number;
  sentCount?: number;
}

interface CreateCampaignInput {
  name: string;
  type: 'SMS' | 'EMAIL' | 'WHATSAPP' | 'PROMO';
  target: 'ALL' | 'MEMBERS' | 'ACTIVE' | 'INACTIVE';
  content: string;
  promoCode?: string;
}

interface CreatePromoInput {
  name: string;
  type: 'PERCENTAGE' | 'FIXED';
  value: number;
  code: string;
  startDate: string;
  endDate: string;
}

class MarketingService {
  async getCampaigns(tenantId: string): Promise<Campaign[]> {
    // In production, you'd have a campaigns table
    // For now, return mock data or empty array
    return [];
  }

  async createCampaign(tenantId: string, data: CreateCampaignInput): Promise<Campaign> {
    // In production, save to campaigns table
    // For now, return mock data
    const targetCount = await this.getTargetCount(tenantId, data.target);

    return {
      id: `campaign-${Date.now()}`,
      name: data.name,
      type: data.type,
      status: 'DRAFT',
      targetCount,
      sentCount: 0,
    };
  }

  async sendCampaign(tenantId: string, campaignId: string): Promise<any> {
    // In production, implement actual sending logic
    // For SMS: integrate with SMS gateway
    // For Email: use Nodemailer
    // For WhatsApp: integrate with WhatsApp Business API
    return {
      campaignId,
      status: 'SENT',
      sentAt: new Date(),
      sentCount: 0,
    };
  }

  async createPromo(tenantId: string, data: CreatePromoInput): Promise<any> {
    // In production, save to promos table
    // For now, return mock data
    return {
      id: `promo-${Date.now()}`,
      ...data,
      tenantId,
      createdAt: new Date(),
    };
  }

  private async getTargetCount(tenantId: string, target: string): Promise<number> {
    switch (target) {
      case 'ALL':
        return await prisma.customer.count({ where: { tenantId } });
      case 'MEMBERS':
        return await prisma.member.count({ where: { tenantId, isActive: true } });
      case 'ACTIVE':
        // Customers with orders in last 30 days
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const activeCustomers = await prisma.order.findMany({
          where: {
            tenantId,
            createdAt: { gte: thirtyDaysAgo },
          },
          distinct: ['customerId'],
        });
        return activeCustomers.length;
      case 'INACTIVE':
        // Customers without orders in last 90 days
        const ninetyDaysAgo = new Date();
        ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
        const allCustomers = await prisma.customer.count({ where: { tenantId } });
        const inactiveCustomers = await prisma.order.findMany({
          where: {
            tenantId,
            createdAt: { gte: ninetyDaysAgo },
          },
          distinct: ['customerId'],
        });
        return allCustomers - inactiveCustomers.length;
      default:
        return 0;
    }
  }
}

export default new MarketingService();

